# frozen_string_literal: true

require "test_helper"

class Api::V1::CryptoHoldingsControllerTest < ActionDispatch::IntegrationTest
  def test_holdings_report_per_pair_quote_currency
    user = User.create!(email: "crypto-hold-#{SecureRandom.hex(4)}@example.com", password: "password123")

    btcphp = CryptoCurrency.create!(name: "Bitcoin", ticker: "BTC", quote_token: "PHP", last_price: 4_640_000.0, last_price_at: Time.zone.now, datasource: nil)
    solusdt = CryptoCurrency.create!(name: "Solana", ticker: "SOL", quote_token: "USDT", last_price: 119.62, last_price_at: Time.zone.now, datasource: nil)
    CryptoCurrency.create!(name: "Tether USD", ticker: "USDT", quote_token: "PHP", last_price: 62.62, last_price_at: Time.zone.now, datasource: nil)

    CryptoActivity.create!(user: user, crypto_currency: btcphp, activity_type: "buy", crypto_amount: 0.001, fiat_amount: 4_640.0, activity_date: Date.new(2026, 1, 5))
    CryptoActivity.create!(user: user, crypto_currency: solusdt, activity_type: "buy", crypto_amount: 2, fiat_amount: 220.0, activity_date: Date.new(2026, 1, 6))

    sign_in user
    get "/api/v1/crypto/holdings"
    assert_response :success

    body = JSON.parse(response.body)
    btc = body["holdings"].find { |h| h["symbol"] == "BTC" }
    sol = body["holdings"].find { |h| h["symbol"] == "SOL" }
    assert_equal "PHP", btc["currency"], "BTC holding must report the BTCPHP pair's quote"
    assert_equal "USDT", sol["currency"], "SOL holding must report the SOLUSDT pair's quote"

    # The market USDT/PHP rate (from the USDT/PHP pair) powers the PHP aggregates.
    assert_kind_of Numeric, body["usdt_php"]
    assert_in_delta 62.62, body["usdt_php"], 0.01
  end
end
