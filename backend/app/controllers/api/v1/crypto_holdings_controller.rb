# frozen_string_literal: true

class Api::V1::CryptoHoldingsController < Api::V1::BaseController
  def index
    user_id = current_user.id
    activities = CryptoActivity.where(user_id: user_id)
    currency_ids = activities.select(:crypto_currency_id).distinct
    currencies = CryptoCurrency.where(id: currency_ids).order(:ticker)

    holdings = currencies.map do |crypto|
      amount = CryptoActivity.net_crypto_amount(user_id, crypto.id).to_f
      next if amount <= 0

      rate = CryptoActivity.cost_basis(user_id, crypto.id).to_f
      {
        symbol: crypto.ticker,
        name: crypto.name,
        amount:,
        avg_cost: round2(rate),
        last_price: crypto.last_price,
        last_price_at: crypto.last_price_at
      }
    end.compact

    currency_name = activities.first&.fiat_currency || "PHP"
    render json: { currency: currency_name, holdings: }
  end
end
