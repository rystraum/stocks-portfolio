# frozen_string_literal: true

require "test_helper"

class GeminiClientTest < ActiveSupport::TestCase
  test "grounded_search parses text, citations and queries from steps" do
    response = OpenStruct.new(code: "200", body: grounded_response_body)

    stub_httparty(:post, response) do
      result = GeminiClient.new(api_key: "test-key").grounded_search("Why did MER move?")

      assert_equal "The stock rose after earnings. Volume spiked.", result[:text]
      assert_equal [{ title: "Manila Bulletin", url: "https://example.com/a" }, { title: "PSE Edge", url: "https://example.com/b" }],
                   result[:citations]
      assert_equal ["MER July 27 2021 price move", "MER earnings disclosure"], result[:queries]
    end
  end

  test "grounded_search dedupes citations by url" do
    response = OpenStruct.new(code: "200", body: grounded_response_body(duplicate_citations: true))

    stub_httparty(:post, response) do
      result = GeminiClient.new(api_key: "test-key").grounded_search("Why did MER move?")

      assert_equal 2, result[:citations].length
    end
  end

  test "grounded_search raises and logs a failed ai call when the api rejects the request" do
    response = OpenStruct.new(code: "400", body: '{"error":{"message":"bad request"}}')

    stub_httparty(:post, response) do
      assert_raises(GeminiClient::Error) { GeminiClient.new(api_key: "test-key").grounded_search("Why did MER move?") }
    end

    ai_call = AiCall.last
    assert_equal "grounded_search", ai_call.purpose
    assert_equal "failed", ai_call.status
    assert_equal '{"error":{"message":"bad request"}}', ai_call.response_body
  end

  test "grounded_search logs a completed ai call" do
    response = OpenStruct.new(code: "200", body: grounded_response_body)

    stub_httparty(:post, response) do
      GeminiClient.new(api_key: "test-key").grounded_search("Why did MER move?")
    end

    ai_call = AiCall.last
    assert_equal "grounded_search", ai_call.purpose
    assert_equal "completed", ai_call.status
    assert_equal "Why did MER move?", ai_call.prompt
    assert_equal grounded_response_body, ai_call.response_body
  end

  test "extract_structured logs the prompt with a pdf size note, never the base64 pdf" do
    response = OpenStruct.new(code: "200", body: extract_response_body('[{"type":"buy"}]'))

    stub_httparty_capture([response]) do |_calls|
      GeminiClient.new(api_key: "test-key").extract_structured("Parse this", StringIO.new("%PDF-fake"))
    end

    ai_call = AiCall.last
    assert_equal "extract_structured", ai_call.purpose
    assert_equal "completed", ai_call.status
    assert_includes ai_call.prompt, "Parse this"
    assert_includes ai_call.prompt, "[PDF attached: 9 bytes]"
    assert_not_includes ai_call.prompt, Base64.strict_encode64("%PDF-fake")
  end

  test "extract_structured logs both the rejected inline attempt and the fallback" do
    rejected = OpenStruct.new(code: "400", body: '{"error":{"message":"unsupported media"}}')
    ok = OpenStruct.new(code: "200", body: extract_response_body('[{"type":"sell"}]'))
    client = GeminiClient.new(api_key: "test-key")
    client.define_singleton_method(:pdftotext_extract) { |_content| "extracted statement text" }

    stub_httparty_capture([rejected, ok]) do |_calls|
      client.extract_structured("Parse this", StringIO.new("%PDF-fake"))
    end

    assert_equal %w[failed completed], AiCall.order(:created_at).last(2).map(&:status)
  end

  test "logs a failed ai call when the request raises" do
    original = HTTParty.method(:post)
    HTTParty.define_singleton_method(:post) { |_url, *_args| raise Errno::ECONNREFUSED }

    assert_raises(Errno::ECONNREFUSED) { GeminiClient.new(api_key: "test-key").grounded_search("Why did MER move?") }

    ai_call = AiCall.last
    assert_equal "failed", ai_call.status
    assert_match(/Connection refused/, ai_call.error_message)
  ensure
    HTTParty.define_singleton_method(:post, original.to_proc)
  end

  test "initialize raises when no api key is configured" do
    Rails.application.credentials.stub(:dig, nil) do
      error = assert_raises(RuntimeError) { GeminiClient.new(api_key: nil, model: nil) }
      assert_match(/API key is not configured/, error.message)
    end
  end

  test "initialize falls back to the default model" do
    client = GeminiClient.new(api_key: "test-key")

    assert_equal GeminiClient::DEFAULT_MODEL, client.instance_variable_get(:@model)
  end

  test "extract_structured sends the pdf inline without tools and parses fenced json" do
    response = OpenStruct.new(code: "200", body: extract_response_body("```json\n[{\"type\":\"buy\"}]\n```"))

    stub_httparty_capture([response]) do |calls|
      result = GeminiClient.new(api_key: "test-key").extract_structured("Parse this", StringIO.new("%PDF-fake"))

      assert_equal [{ "type" => "buy" }], result

      body = JSON.parse(calls.first.last[:body])
      assert_nil body["tools"]
      assert_equal 2, body["input"].length
      assert_equal({ "type" => "text", "text" => "Parse this" }, body["input"].first)
      assert_equal "document", body["input"].last["type"]
      assert_equal "application/pdf", body["input"].last["mime_type"]
      assert_equal Base64.strict_encode64("%PDF-fake"), body["input"].last["data"]
    end
  end

  test "extract_structured falls back to pdftotext when the api rejects the inline pdf" do
    rejected = OpenStruct.new(code: "400", body: '{"error":{"message":"unsupported media"}}')
    ok = OpenStruct.new(code: "200", body: extract_response_body('[{"type":"sell"}]'))
    client = GeminiClient.new(api_key: "test-key")
    client.define_singleton_method(:pdftotext_extract) { |_content| "extracted statement text" }

    stub_httparty_capture([rejected, ok]) do |calls|
      result = client.extract_structured("Parse this", StringIO.new("%PDF-fake"))

      assert_equal [{ "type" => "sell" }], result
      assert_equal 2, calls.length
      assert_kind_of Array, JSON.parse(calls.first.last[:body])["input"]
      fallback_input = JSON.parse(calls.last.last[:body])["input"]
      assert_kind_of String, fallback_input
      assert_includes fallback_input, "extracted statement text"
    end
  end

  test "extract_structured raises when both the inline pdf and the fallback are rejected" do
    rejected = OpenStruct.new(code: "400", body: '{"error":{"message":"unsupported media"}}')
    client = GeminiClient.new(api_key: "test-key")
    client.define_singleton_method(:pdftotext_extract) { |_content| "extracted statement text" }

    stub_httparty_capture([rejected, rejected]) do |_calls|
      assert_raises(GeminiClient::Error) { client.extract_structured("Parse this", StringIO.new("%PDF-fake")) }
    end
  end

  test "extract_structured raises with the raw text when the response is not json" do
    response = OpenStruct.new(code: "200", body: extract_response_body("Sorry, I cannot parse this."))

    stub_httparty_capture([response]) do |_calls|
      error = assert_raises(GeminiClient::ParseError) do
        GeminiClient.new(api_key: "test-key").extract_structured("Parse this", StringIO.new("%PDF-fake"))
      end
      assert_includes error.message, "Sorry, I cannot parse this."
    end
  end

  private

  def extract_response_body(text)
    {
      "steps" => [
        { "signature" => "abc", "type" => "thought" },
        { "type" => "model_output", "content" => [{ "type" => "text", "text" => text }] },
      ]
    }.to_json
  end

  def stub_httparty_capture(responses)
    calls = []
    original = HTTParty.method(:post)
    HTTParty.define_singleton_method(:post) do |_url, *args|
      calls << args
      responses[[calls.length - 1, responses.length - 1].min]
    end
    yield calls
  ensure
    HTTParty.define_singleton_method(:post, original.to_proc)
  end

  def grounded_response_body(duplicate_citations: false)
    citations = [
      { "type" => "url_citation", "title" => "Manila Bulletin", "url" => "https://example.com/a", "start_index" => 0, "end_index" => 10 },
      { "type" => "url_citation", "title" => "PSE Edge", "url" => "https://example.com/b", "start_index" => 11, "end_index" => 20 },
    ]
    if duplicate_citations
      citations << { "type" => "url_citation", "title" => "Duplicate", "url" => "https://example.com/a", "start_index" => 21, "end_index" => 30 }
    end

    {
      "steps" => [
        { "type" => "thought", "summary" => [{ "type" => "text", "text" => "thinking" }] },
        { "type" => "google_search_call", "arguments" => { "queries" => ["MER July 27 2021 price move"] } },
        { "type" => "google_search_result", "call_id" => "call-1", "result" => [] },
        {
          "type" => "model_output",
          "content" => [
            { "type" => "text", "text" => "The stock rose after earnings.", "annotations" => citations },
            { "type" => "text", "text" => " Volume spiked." },
          ]
        },
        { "type" => "google_search_call", "arguments" => { "queries" => ["MER earnings disclosure"] } },
      ]
    }.to_json
  end

  def stub_httparty(method_name, response)
    original = HTTParty.method(method_name)
    HTTParty.define_singleton_method(method_name) { |_url, *_args| response }
    yield
  ensure
    HTTParty.define_singleton_method(method_name, original.to_proc)
  end
end
