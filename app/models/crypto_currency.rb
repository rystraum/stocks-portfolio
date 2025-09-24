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
  self.primary_key = :id
  validates :name, presence: true
  validates :ticker, presence: true, uniqueness: true

  scope :alphabetical, -> { order(:ticker) }
  scope :coinsph, -> { where(datasource: "https://api.pro.coins.ph/") }

  def fiat
    return 'USDT' if ticker.end_with?('USDT') && ticker != 'USDT'

    return 'PHP'
  end

  def pretty_ticker
    return ticker if ticker == 'USDT'

    return ticker.gsub('USDT', '')
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
