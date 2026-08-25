# frozen_string_literal: true

require "test_helper"

class PriceMoveExplainerTest < ActiveSupport::TestCase
  KEY_DATES = [
    { date: Date.new(2026, 7, 27), pct_change: 5.0, close_price: 105.0 },
    { date: Date.new(2026, 8, 3), pct_change: -4.2, close_price: 100.6 },
  ].freeze

  test "run! creates insights for uncached key dates" do
    company = Company.create!(ticker: "EXPLAIN", name: "Explain Corp")
    client = FakeGeminiClient.new

    explainer(company, client).run!

    assert_equal 2, client.calls.length
    insights = company.price_move_insights.latest_first
    assert_equal [Date.new(2026, 8, 3), Date.new(2026, 7, 27)], insights.map(&:move_date)
    insight = insights.find_by(move_date: Date.new(2026, 7, 27))
    assert_equal "Explained.", insight.explanation
    assert_equal 90, insight.range_days
    assert_equal 5.0, insight.pct_change.to_f
    assert_equal 105.0, insight.close_price.to_f
    assert_equal [{ "title" => "News", "url" => "https://example.com/news" }], insight.news_items
    assert_equal ["query"], insight.search_queries
  end

  test "run! skips dates that already have a stored insight" do
    company = Company.create!(ticker: "CACHED")
    explainer(company, FakeGeminiClient.new).run!
    assert_equal 2, company.price_move_insights.count

    client = FakeGeminiClient.new
    explainer(company, client).run!

    assert_empty client.calls
    assert_equal 2, company.price_move_insights.count
  end

  test "run! with force re-searches cached dates and updates the rows" do
    company = Company.create!(ticker: "FORCED")
    explainer(company, FakeGeminiClient.new).run!

    client = FakeGeminiClient.new(text: "Updated explanation.")
    PriceMoveExplainer.new(company, range_days: 90, force: true, detector: FakeDetector.new(KEY_DATES), client: client).run!

    assert_equal 2, client.calls.length
    assert_equal 2, company.price_move_insights.count
    assert_equal "Updated explanation.", company.price_move_insights.find_by(move_date: Date.new(2026, 7, 27)).explanation
  end

  test "run! logs and skips a date when the Gemini call fails" do
    company = Company.create!(ticker: "FLAKY")
    client = FakeGeminiClient.new(fail_on: "2026-07-27")

    explainer(company, client).run!

    assert_equal 2, client.calls.length
    assert_equal [Date.new(2026, 8, 3)], company.price_move_insights.map(&:move_date)
  end

  test "run! does nothing when the detector finds no key dates" do
    company = Company.create!(ticker: "NOMOVE")
    client = FakeGeminiClient.new

    PriceMoveExplainer.new(company, detector: FakeDetector.new([]), client: client).run!

    assert_empty client.calls
    assert_equal 0, company.price_move_insights.count
  end

  private

  def explainer(company, client)
    PriceMoveExplainer.new(company, range_days: 90, detector: FakeDetector.new(KEY_DATES), client: client)
  end

  class FakeDetector
    def initialize(key_dates)
      @key_dates = key_dates
    end

    def key_dates(*)
      @key_dates
    end
  end

  class FakeGeminiClient
    attr_reader :calls

    def initialize(text: "Explained.", fail_on: nil)
      @text = text
      @fail_on = fail_on
      @calls = []
    end

    def grounded_search(prompt)
      @calls << prompt
      raise "Gemini API timeout" if @fail_on && prompt.include?(@fail_on)

      { text: @text, citations: [{ title: "News", url: "https://example.com/news" }], queries: ["query"] }
    end
  end
end
