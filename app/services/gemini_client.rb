# frozen_string_literal: true

class GeminiClient
  API_URL = "https://generativelanguage.googleapis.com/v1beta/interactions"
  DEFAULT_MODEL = "gemini-3.7-flash"
  TIMEOUT_SECONDS = 120

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

  private

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
