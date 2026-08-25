# frozen_string_literal: true

require "test_helper"

class GeminiClientTest < ActiveSupport::TestCase
  test "grounded_search parses text, citations and queries from steps" do
    response = OpenStruct.new(body: grounded_response_body)

    stub_httparty(:post, response) do
      result = GeminiClient.new(api_key: "test-key").grounded_search("Why did MER move?")

      assert_equal "The stock rose after earnings. Volume spiked.", result[:text]
      assert_equal [{ title: "Manila Bulletin", url: "https://example.com/a" }, { title: "PSE Edge", url: "https://example.com/b" }],
                   result[:citations]
      assert_equal ["MER July 27 2021 price move", "MER earnings disclosure"], result[:queries]
    end
  end

  test "grounded_search dedupes citations by url" do
    response = OpenStruct.new(body: grounded_response_body(duplicate_citations: true))

    stub_httparty(:post, response) do
      result = GeminiClient.new(api_key: "test-key").grounded_search("Why did MER move?")

      assert_equal 2, result[:citations].length
    end
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

  private

  def grounded_response_body(duplicate_citations: false)
    citations = [
      { "title" => "Manila Bulletin", "url" => "https://example.com/a" },
      { "title" => "PSE Edge", "url" => "https://example.com/b" },
    ]
    citations << { "title" => "Duplicate", "url" => "https://example.com/a" } if duplicate_citations

    {
      "steps" => [
        { "type" => "google_search_call", "query" => "MER July 27 2021 price move" },
        {
          "type" => "model_output",
          "content" => {
            "blocks" => [
              { "type" => "text", "text" => "The stock rose after earnings.", "annotations" => { "url_citations" => citations } },
              { "type" => "text", "text" => " Volume spiked." },
            ]
          }
        },
        { "type" => "google_search_call", "query" => "MER earnings disclosure" },
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
