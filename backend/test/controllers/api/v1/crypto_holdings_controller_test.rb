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

  def test_show_returns_position_and_activities
    user = User.create!(email: "crypto-show-#{SecureRandom.hex(4)}@example.com", password: "password123")
    btcphp = CryptoCurrency.create!(name: "Bitcoin", ticker: "BTC", quote_token: "PHP", last_price: 4_640_000.0, last_price_at: Time.zone.now, datasource: nil)

    CryptoActivity.create!(user: user, crypto_currency: btcphp, activity_type: "buy", crypto_amount: 0.001, fiat_amount: 4_640.0, activity_date: Date.new(2026, 1, 5))
    CryptoActivity.create!(user: user, crypto_currency: btcphp, activity_type: "sell", crypto_amount: 0.0005, fiat_amount: 2_320.0, fee_fiat: 2.32, activity_date: Date.new(2026, 2, 5))

    sign_in user
    get "/api/v1/crypto/holdings/BTCPHP"
    assert_response :success

    body = JSON.parse(response.body)
    assert_equal "BTC", body["symbol"]
    assert_equal "BTCPHP", body["compound"]
    assert_equal "PHP", body["currency"]
    assert_in_delta 0.0005, body["amount"], 1e-9
    assert_in_delta 4_640_000.0, body["avg_cost"], 1.0
    assert_in_delta 4_640.0, body["total_fiat"], 0.01
    assert_in_delta 2_317.68, body["total_proceeds"], 0.01
    assert_in_delta 2_320.0, body["current_value"], 0.01
    assert_in_delta -2.32, body["pnl"], 0.01

    assert_equal 2, body["activities"].length
    first = body["activities"][0]
    assert_equal "sell", first["type"]
    assert_equal "2026-02-05", first["date"]
  end

  def test_show_404s_for_unknown_pair
    user = User.create!(email: "crypto-404-#{SecureRandom.hex(4)}@example.com", password: "password123")
    sign_in user
    get "/api/v1/crypto/holdings/NOPE123"
    assert_response :not_found
  end
end
