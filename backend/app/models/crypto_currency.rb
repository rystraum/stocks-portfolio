# frozen_string_literal: true

# == Schema Information
#
# Table name: crypto_currencies
#
#  id          :uuid             not null, primary key
#  name        :string           not null
#  ticker      :string           not null
#  last_price  :decimal(30, 20)
#  last_price_at :datetime
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class CryptoCurrency < ApplicationRecord
  COINSPH_DATASOURCE = "https://api.pro.coins.ph/"
  COINMARKETCAP_DATASOURCE = "https://pro-api.coinmarketcap.com/"

  self.primary_key = :id
  validates :name, presence: true
  validates :ticker, presence: true, uniqueness: { scope: :quote_token }
  validates :quote_token, presence: true
  validates :compound_ticker, presence: true

  before_validation :set_compound_ticker

  validate :datasource_ticker_validation

  scope :alphabetical, -> { order(:ticker) }
  scope :coinsph, -> { where(datasource: COINSPH_DATASOURCE) }
  scope :coinmarketcap, -> { where(datasource: COINMARKETCAP_DATASOURCE) }

  def coinmarketcap?
    datasource == COINMARKETCAP_DATASOURCE
  end

  def coinsph?
    datasource == COINSPH_DATASOURCE
  end

  def datasource_ticker_validation
    return true if datasource.nil?

    if coinmarketcap? && (datasource_ticker.blank? || Float(datasource_ticker, exception: false).nil?)
      errors.add(:datasource_ticker, "is required & must be an ID")
    end

    errors.add(:datasource_ticker, "is required") if coinsph? && datasource_ticker.blank?
  end

  def fiat
    return quote_token if quote_token.present?

    return "USDT" if ticker.end_with?("USDT") && ticker != "USDT"
    return "USDC" if ticker.end_with?("USDC") && ticker != "USDC"

    return "PHP"
  end

  def pretty_ticker
    return ticker if %w[USDT USDC].include?(ticker)

    return ticker.gsub("USDT", "").gsub("USDC", "")
  end

  def is_php?
    quote_token == "PHP"
  end

  def to_s
    compound_ticker
  end

  def to_param
    compound_ticker
  end

  private

  def set_compound_ticker
    self.compound_ticker = "#{ticker}#{quote_token}"
  end
end
