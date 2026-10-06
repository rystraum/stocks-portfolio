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

  # GET /api/v1/crypto/holdings/:id  (id = compound ticker, e.g. BNBPHP)
  def show
    crypto = CryptoCurrency.find_by(compound_ticker: params[:id])
    return render json: { error: { code: "not_found", message: "No such pair" } }, status: :not_found if crypto.nil?

    user_id = current_user.id
    amount = CryptoActivity.net_crypto_amount(user_id, crypto.id).to_f
    avg_cost = CryptoActivity.cost_basis(user_id, crypto.id).to_f
    total_fiat = CryptoActivity.total_fiat_spent(user_id, crypto.id).to_f
    total_proceeds = CryptoActivity.where(crypto_currency_id: crypto.id, user_id: user_id, activity_type: :sell)
                             .sum("fiat_amount - COALESCE(fee_fiat, 0)").to_f
    current_value = crypto.last_price ? amount * crypto.last_price : 0
    current_value = 0 if current_value.negative?
    pnl = current_value + total_proceeds - total_fiat

    activities = CryptoActivity.where(user_id: user_id, crypto_currency_id: crypto.id)
                             .order(activity_date: :desc, created_at: :desc)
                             .map do |a|
                               {
                                 date: a.activity_date.iso8601,
                                 type: a.activity_type,
                                 crypto_amount: a.crypto_amount.to_f,
                                 fiat_amount: a.fiat_amount.to_f,
                                 fee_crypto: a.fee_crypto&.to_f,
                                 fee_fiat: a.fee_fiat&.to_f,
                                 forex: a.fiat_forex.to_f,
                                 notes: a.notes
                               }
                             end

    render json: {
      symbol: crypto.ticker,
      name: crypto.name,
      currency: crypto.fiat,
      compound: crypto.compound_ticker,
      last_price: crypto.last_price&.to_f,
      last_price_at: crypto.last_price_at,
      amount:,
      avg_cost:,
      total_fiat:,
      total_proceeds:,
      current_value: current_value.to_f,
      pnl: pnl.to_f,
      activities:
    }
  end
end
