# frozen_string_literal: true

require "base64"
require "open3"

class GeminiClient
  API_URL = "https://generativelanguage.googleapis.com/v1beta/interactions"
  DEFAULT_MODEL = "gemini-3.7-flash"
  TIMEOUT_SECONDS = 120
  PDFTOTEXT_BIN = "/opt/homebrew/bin/pdftotext"

  class Error < StandardError; end
  class ParseError < Error; end

  def initialize(api_key: nil, model: nil)
    @api_key = api_key.presence || Rails.application.credentials.dig(:gemini, :api_key).presence || ENV["GEMINI_API_KEY"].presence
    @model = model.presence || Rails.application.credentials.dig(:gemini, :model).presence || ENV["GEMINI_MODEL"].presence || DEFAULT_MODEL
    raise "Gemini API key is not configured (set credentials gemini.api_key or ENV GEMINI_API_KEY)" if @api_key.blank?
  end

  def grounded_search(prompt)
    response = HTTParty.post(
      API_URL,
      headers: { "x-goog-api-key" => @api_key, "Content-Type" => "application/json" },
      body: { model: @model, input: prompt, tools: [{ type: "google_search" }] }.to_json,
      timeout: TIMEOUT_SECONDS,
    )

    parse(JSON.parse(response.body))
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

    payload = post_interactions(inline_input)
    if payload.nil?
      Rails.logger.warn "GeminiClient: inline PDF request rejected, falling back to pdftotext"
      text_input = "#{prompt}\n\nStatement text extracted with pdftotext -layout:\n\n#{pdftotext_extract(pdf_content)}"
      payload = post_interactions(text_input)
    end

    raise Error, "Gemini API rejected both the inline PDF and the pdftotext fallback request" if payload.nil?

    parse_json_payload(payload)
  end

  private

  # Returns the parsed response body, or nil when the API rejects the request.
  def post_interactions(input)
    response = HTTParty.post(
      API_URL,
      headers: { "x-goog-api-key" => @api_key, "Content-Type" => "application/json" },
      body: { model: @model, input: input }.to_json,
      timeout: TIMEOUT_SECONDS,
    )
    return nil unless response.code.to_i == 200

    JSON.parse(response.body)
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
        queries << step["query"] if step["query"].present?
      end
    end

    { text: text, citations: citations.uniq { |citation| citation[:url] }, queries: queries }
  end

  def collect_model_output(step, text, citations)
    Array(step.dig("content", "blocks")).each do |block|
      next unless block["type"] == "text"

      text << block["text"].to_s
      Array(block.dig("annotations", "url_citations")).each do |citation|
        citations << { title: citation["title"], url: citation["url"] }
      end
    end

    [text, citations]
  end
end
