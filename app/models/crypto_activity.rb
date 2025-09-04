class CryptoActivity < ApplicationRecord
  belongs_to :crypto_currency
  belongs_to :user

  enum activity_type: { buy: 0, sell: 1 }

  validates :activity_type, :crypto_currency_id, :user_id, :crypto_amount, :fiat_amount, :fiat_currency,
            :activity_date, presence: true

  # Returns the net crypto amount (buy minus sell minus fees) for cost basis calculations
  def self.net_crypto_amount(user_id, crypto_currency_id)
    where(
      user_id: user_id,
      crypto_currency_id: crypto_currency_id,
    ).sum('CASE WHEN activity_type = 0 THEN crypto_amount - COALESCE(fee_crypto, 0) WHEN activity_type = 1 THEN -crypto_amount ELSE 0 END')
  end

  # Returns the total fiat spent for buys (for cost basis), subtracting fiat fees
  def self.total_fiat_spent(user_id, crypto_currency_id)
    where(
      user_id: user_id,
      crypto_currency_id: crypto_currency_id,
      activity_type: :buy,
    ).sum('fiat_amount - COALESCE(fee_fiat, 0)')
  end

  # Cost basis: total fiat spent (minus PHP fees) / total crypto acquired (excluding crypto fees from buys)
  def self.cost_basis(user_id, crypto_currency_id)
    activities = where(
      user_id: user_id,
      crypto_currency_id: crypto_currency_id,
    ).order('activity_date asc')

    return 0 if activities.empty?

    fiat = 0
    crypto = 0

    activities.each do |activity|
      if activity.buy?
        fiat += activity.fiat_amount
        crypto += activity.crypto_amount - (activity.fee_crypto || 0)
      else
        fiat -= activity.fiat_amount - (activity.fee_fiat || 0)
        crypto -= activity.crypto_amount
      end
    end

    return 0 if crypto.zero?

    return fiat / crypto
  end

  # Computes the fiat conversion rate (fiat per 1 crypto) based on net crypto and net fiat spent (after fees)
  def fiat_forex
    net_crypto = crypto_amount - (fee_crypto || 0)
    net_fiat = fiat_amount - (fee_fiat || 0)

    return 0 if net_crypto.to_d.zero?

    net_fiat.to_d / net_crypto.to_d
  end
end
