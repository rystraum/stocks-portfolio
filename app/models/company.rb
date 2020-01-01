# frozen_string_literal: true

class Company < ApplicationRecord
  validates :ticker, uniqueness: true, presence: true
  has_many :activities
  has_many :stock_dividends
  has_many :cash_dividends
  has_many :price_updates

  scope :alphabetical, -> { order(:ticker) }

  def to_s
    "#{ticker} [#{id}]"
  end

  def dividends
    (stock_dividends + cash_dividends).sort_by(&:pay_date)
  end

  def total_shares
    @total_shares ||= bought_shares - sold_shares + stock_dividend_shares
  end

  def total_costs
    @total_costs ||= buy_costs - sell_gains
  end

  def last_price
    @last_price ||= price_updates.order('datetime desc').first.price
  end

  def last_value
    @last_value ||= total_shares * last_price
  end

  def profit_loss
    @profit_loss ||= last_value - total_costs
  end

  def cash_dividends_total
    cash_dividends.pluck(:amount).sum
  end

  def history
    @history ||= (activities + stock_dividends + cash_dividends).sort_by do |thing|
      thing.is_a?(Activity) ? thing.date : thing.pay_date
    end
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
