# frozen_string_literal: true

class CryptoActivity < ApplicationRecord
  belongs_to :crypto_currency
  belongs_to :user
  belongs_to :crypto_activity_import, optional: true

  CLOSE_MATCH_TOLERANCE = BigDecimal("0.005") # 0.5% on both amounts

  # Finds a manually-entered or CSV-imported activity (no upstream reference)
  # that looks like the same transaction as a pulled upstream trade, so the
  # user can decide whether the trade is already recorded under another form.
  def self.close_candidate_for(user_id:, crypto_currency_id:, activity_type:, crypto_amount:, fiat_amount:, activity_date:)
    where(
      user_id: user_id,
      crypto_currency_id: crypto_currency_id,
      activity_type: activity_type,
      upstream_trade_id: nil,
    ).where(activity_date: (activity_date - 3)..(activity_date + 3))
      .find do |a|
        (a.crypto_amount - crypto_amount).abs <= crypto_amount * CLOSE_MATCH_TOLERANCE &&
          (a.fiat_amount - fiat_amount).abs <= fiat_amount * CLOSE_MATCH_TOLERANCE
      end
  end

  enum :activity_type, { buy: 0, sell: 1 }

  before_validation :set_fiat_currency
  validates :activity_type, :crypto_currency_id, :user_id, :crypto_amount, :fiat_amount, :fiat_currency,
            :activity_date, presence: true

  # Returns the net crypto amount (buy minus sell minus fees) for cost basis calculations
  def self.net_crypto_amount(user_id, crypto_currency_id)
    where(
      user_id: user_id,
      crypto_currency_id: crypto_currency_id,
    ).sum("CASE WHEN activity_type = 0 THEN crypto_amount - COALESCE(fee_crypto, 0) WHEN activity_type = 1 THEN -crypto_amount ELSE 0 END")
  end

  # Returns the total fiat spent for buys (for cost basis), subtracting fiat fees
  def self.total_fiat_spent(user_id, crypto_currency_id)
    where(
      user_id: user_id,
      crypto_currency_id: crypto_currency_id,
      activity_type: :buy,
    ).sum("fiat_amount - COALESCE(fee_fiat, 0)")
  end

  # Cost basis: total fiat spent (minus PHP fees) / total crypto acquired (excluding crypto fees from buys)
  def self.cost_basis(user_id, crypto_currency_id)
    activities = where(
      user_id: user_id,
      crypto_currency_id: crypto_currency_id,
    ).order("activity_date asc")

    return 0 if activities.empty?

    cost_basis_calculator = CostBasisCalculator.new(activities)
    cost_basis_calculator.cost_basis!

    return 0 if cost_basis_calculator.crypto.zero?

    return cost_basis_calculator.rate
  end

  # Computes the fiat conversion rate (fiat per 1 crypto) based on net crypto and net fiat spent (after fees)
  def fiat_forex
    net_crypto = crypto_amount - (fee_crypto || 0)
    net_fiat = fiat_amount - (fee_fiat || 0)

    return 0 if net_crypto.to_d.zero?

    net_fiat.to_d / net_crypto.to_d
  end

  def set_fiat_currency
    self.fiat_currency = crypto_currency.fiat
  end
end
