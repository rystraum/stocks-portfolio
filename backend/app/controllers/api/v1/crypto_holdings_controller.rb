# frozen_string_literal: true

class Api::V1::CryptoHoldingsController < Api::V1::BaseController
  def index
    user_id = current_user.id
    activities = CryptoActivity.where(user_id: user_id)
    currency_ids = activities.select(:crypto_currency_id).distinct
    currencies = CryptoCurrency.where(id: currency_ids).order(:ticker)

    usdt_php = CryptoCurrency.find_by(ticker: "USDT", quote_token: "PHP")&.last_price&.to_f

    holdings = currencies.map do |crypto|
      amount = CryptoActivity.net_crypto_amount(user_id, crypto.id).to_f
      next if amount <= 0

      rate = CryptoActivity.cost_basis(user_id, crypto.id).to_f
      {
        symbol: crypto.ticker,
        name: crypto.name,
        currency: crypto.fiat,
        amount:,
        avg_cost: rate,
        last_price: crypto.last_price&.to_f,
        last_price_at: crypto.last_price_at
      }
    end.compact

    render json: { usdt_php: usdt_php, holdings: }
  end
end
