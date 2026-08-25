# frozen_string_literal: true

require "base64"
require "open3"

class GeminiClient
  API_URL = "https://generativelanguage.googleapis.com/v1beta/interactions"
  DEFAULT_MODEL = "gemini-3.7-flash"
  TIMEOUT_SECONDS = 120
  PDFTOTEXT_BIN = "/opt/homebrew/bin/pdftotext"
  MAX_LOGGED_RESPONSE_BYTES = 50.kilobytes

  class Error < StandardError; end
  class ParseError < Error; end

  def initialize(api_key: nil, model: nil)
    @api_key = api_key.presence || Rails.application.credentials.dig(:gemini, :api_key).presence || ENV["GEMINI_API_KEY"].presence
    @model = model.presence || Rails.application.credentials.dig(:gemini, :model).presence || ENV["GEMINI_MODEL"].presence || DEFAULT_MODEL
    raise "Gemini API key is not configured (set credentials gemini.api_key or ENV GEMINI_API_KEY)" if @api_key.blank?
  end

  def grounded_search(prompt)
    payload = post_interactions(
      { model: @model, input: prompt, tools: [{ type: "google_search" }] },
      purpose: "grounded_search",
      log_prompt: prompt,
    )
    raise Error, "Gemini API rejected the grounded search request" if payload.nil?

    parse(payload)
  end

  # Sends the PDF inline (base64) without any tools and parses the model output
  # as JSON. Falls back to locally extracted pdftotext text when the API
  # rejects the inline PDF request.
  def extract_structured(prompt, pdf_io)
    pdf_content = pdf_io.read
    inline_input = [
      { type: "text", text: prompt },
      { type: "document", data: Base64.strict_encode64(pdf_content), mime_type: "application/pdf" },
    ]
    log_prompt = "#{prompt}\n\n[PDF attached: #{pdf_content.bytesize} bytes]"

    payload = post_interactions({ model: @model, input: inline_input }, purpose: "extract_structured", log_prompt: log_prompt)
    if payload.nil?
      Rails.logger.warn "GeminiClient: inline PDF request rejected, falling back to pdftotext"
      text_input = "#{prompt}\n\nStatement text extracted with pdftotext -layout:\n\n#{pdftotext_extract(pdf_content)}"
      payload = post_interactions({ model: @model, input: text_input }, purpose: "extract_structured", log_prompt: log_prompt)
    end

    raise Error, "Gemini API rejected both the inline PDF and the pdftotext fallback request" if payload.nil?

    parse_json_payload(payload)
  end

  private

  # Posts one interaction and logs the call as an AiCall row. Returns the
  # parsed response body, or nil when the API rejects the request.
  def post_interactions(request_body, purpose:, log_prompt:)
    response = HTTParty.post(
      API_URL,
      headers: { "x-goog-api-key" => @api_key, "Content-Type" => "application/json" },
      body: request_body.to_json,
      timeout: TIMEOUT_SECONDS,
    )

    log_ai_call(purpose: purpose, log_prompt: log_prompt, response_body: response.body,
                status: response.code.to_i == 200 ? "completed" : "failed",)
    return nil unless response.code.to_i == 200

    JSON.parse(response.body)
  rescue StandardError => e
    log_ai_call(purpose: purpose, log_prompt: log_prompt, status: "failed", error_message: e.message)
    raise
  end

  # Logging must never break the caller.
  def log_ai_call(purpose:, log_prompt:, status:, response_body: nil, error_message: nil)
    AiCall.create!(
      purpose: purpose,
      model: @model,
      prompt: log_prompt,
      response_body: response_body&.truncate(MAX_LOGGED_RESPONSE_BYTES),
      status: status,
      error_message: error_message,
    )
  rescue StandardError => e
    Rails.logger.error "GeminiClient: failed to log AI call: #{e.message}"
  end

  def pdftotext_extract(pdf_content)
    stdout, stderr, status = Open3.capture3(PDFTOTEXT_BIN, "-layout", "-", "-", stdin_data: pdf_content)
    raise Error, "pdftotext failed: #{stderr}" unless status.success?

    stdout
  end

  def parse_json_payload(payload)
    text = parse(payload)[:text]
    stripped = text.strip.gsub(/\A```(?:json)?\s*/, "").gsub(/\s*```\z/, "")

    JSON.parse(stripped)
  rescue JSON::ParserError => e
    raise ParseError, "Failed to parse Gemini response as JSON: #{e.message}. Raw text: #{text}"
  end

  def parse(payload)
    text = +""
    citations = []
    queries = []

    Array(payload["steps"]).each do |step|
      case step["type"]
      when "model_output"
        text, citations = collect_model_output(step, text, citations)
      when "google_search_call"
        queries.concat(Array(step.dig("arguments", "queries")))
      end
    end

    { text: text, citations: citations.uniq { |citation| citation[:url] }, queries: queries }
  end

  def collect_model_output(step, text, citations)
    Array(step["content"]).each do |block|
      next unless block["type"] == "text"

      text << block["text"].to_s
      Array(block["annotations"]).each do |annotation|
        citations << { title: annotation["title"], url: annotation["url"] } if annotation["type"] == "url_citation"
      end
    end

    [text, citations]
  end
end
