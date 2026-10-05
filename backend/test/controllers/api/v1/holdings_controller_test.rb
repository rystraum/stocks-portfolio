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
end
