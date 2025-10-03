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
  COINSPH_DATASOURCE = "https://api.pro.coins.ph/".freeze
  COINMARKETCAP_DATASOURCE = "https://pro-api.coinmarketcap.com/".freeze

  self.primary_key = :id
  validates :name, presence: true
  validates :ticker, presence: true, uniqueness: true
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
    return 'USDT' if ticker.end_with?('USDT') && ticker != 'USDT'
    return 'USDC' if ticker.end_with?('USDC') && ticker != 'USDC'

    return 'PHP'
  end

  def pretty_ticker
    return ticker if ticker == 'USDT' || ticker == 'USDC'

    return ticker.gsub('USDT', '').gsub('USDC', '')
  end

  def is_php?
    fiat == 'PHP'
  end

  def to_s
    ticker
  end

  def to_param
    ticker
  end
end
