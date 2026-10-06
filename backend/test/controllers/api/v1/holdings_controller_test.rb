# frozen_string_literal: true

require "test_helper"

class Api::V1::HoldingsControllerTest < ActionDispatch::IntegrationTest
  def test_holdings_money_fields_are_numbers
    user = User.create!(email: "holdings-num-#{SecureRandom.hex(4)}@example.com", password: "password123")
    company = Company.create!(ticker: "DMC#{SecureRandom.hex(2).upcase}", industry: "Mining", name: "DMC Inc")
    PriceUpdate.create!(company: company, price: 7.61, datetime: DateTime.now)
    Activity.create!(user: user, company: company, activity_type: "buy", number_of_shares: 1000, total_price: 7610.0, date: Date.new(2026, 1, 10))
    CashDividend.create!(user: user, company: company, amount: 875.26, pay_date: Date.new(2026, 1, 15), ex_date: Date.new(2026, 1, 10))

    sign_in user
    get "/api/v1/holdings"
    assert_response :success

    body = JSON.parse(response.body)
    holdings = body.is_a?(Array) ? body : body["holdings"]
    holding = holdings.find { |h| h["ticker"] == company.ticker }
    assert holding, "expected a holding for #{company.ticker} in the response"

    # The DECIMAL money fields must serialize as JSON numbers (not strings) so the
    # frontend's arithmetic does not produce NaN.
    assert_kind_of Numeric, holding["total_cost"], "total_cost should be a number, got #{holding['total_cost'].inspect}"
    assert_kind_of Numeric, holding["dividends"], "dividends should be a number, got #{holding['dividends'].inspect}"
    assert_kind_of Numeric, holding["last_price"], "last_price should be a number, got #{holding['last_price'].inspect}"
  end

  def test_price_history_aggregates_to_daily_bars
    user = User.create!(email: "price-hist-#{SecureRandom.hex(4)}@example.com", password: "password123")
    company = Company.create!(ticker: "AGG#{SecureRandom.hex(2).upcase}", industry: "Mining", name: "AGG Inc")

    d1 = Date.new(2026, 9, 28)
    # Two updates on the same date: the chart must get a single candle for it.
    PriceUpdate.create!(company: company, datetime: d1.to_time.change(hour: 9), price: 100.0, open: 102.0, high: 103.0, low: 99.0)
    PriceUpdate.create!(company: company, datetime: d1.to_time.change(hour: 16), price: 101.5, open: 101.0, high: 104.0, low: 100.5)
    # A second date with a single update.
    PriceUpdate.create!(company: company, datetime: (d1 + 1).to_time, price: 102.25, open: 101.5, high: 102.5, low: 101.0)
    # A row without OHLC cannot render as a candle and must not appear.
    PriceUpdate.create!(company: company, datetime: (d1 + 2).to_time, price: 103.0)

    sign_in user
    get "/api/v1/holdings/#{company.ticker}/price-history?days=30"
    assert_response :success

    points = JSON.parse(response.body)["points"]
    assert_equal 2, points.length, "expected one point per date, got #{points.length}"

    first = points.find { |p| p["time"] == d1.iso8601 }
    assert_equal 102.0, first["open"], "open should be the first update of the day"
    assert_equal 104.0, first["high"], "high should be the max of the day"
    assert_equal 99.0, first["low"], "low should be the min of the day"
    assert_equal 101.5, first["close"], "close should be the last update of the day"

    second = points.find { |p| p["time"] == (d1 + 1).iso8601 }
    assert_equal 102.25, second["close"]
  end
end
