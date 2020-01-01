# frozen_string_literal: true

class Company < ApplicationRecord
  validates :ticker, uniqueness: true, presence: true
  has_many :activities
  has_many :stock_dividends
  has_many :cash_dividends

  scope :alphabetical, -> { order(:ticker) }

  def to_s
    "#{ticker} [#{id}]"
  end

  def total_shares
    bought_shares - sold_shares + stock_dividend_shares
  end

  def total_costs
    buy_costs - sell_gains
  end

  protected

  def bought_shares
    activities.buy.pluck(:number_of_shares).sum
  end

  def sold_shares
    activities.sell.pluck(:number_of_shares).sum
  end

  def stock_dividend_shares
    stock_dividends.pluck(:amount).sum
  end

  def buy_costs
    activities.buy.pluck(:total_price).sum
  end

  def sell_gains
    activities.sell.pluck(:total_price).sum
  end
end
