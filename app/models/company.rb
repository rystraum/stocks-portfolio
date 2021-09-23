# frozen_string_literal: true

class Company < ApplicationRecord
  validates :ticker, uniqueness: true, presence: true
  has_many :activities
  has_many :stock_dividends
  has_many :cash_dividends
  has_many :price_updates

  scope :alphabetical, -> { order(:ticker) }
  scope :active, -> { where(inactive: false) }

  def to_s
    "#{ticker} [#{id}]"
  end

  def dividends
    (stock_dividends + cash_dividends).sort_by(&:pay_date)
  end

  def total_shares
    @total_shares ||= bought_shares - sold_shares + stock_dividend_shares || 0
  end

  def total_costs
    return 0 if total_shares == 0

    actual_total_costs
  end

  def actual_total_costs
    @actual_total_costs ||= buy_costs - sell_gains
  end

  def cps
    return 0 if total_costs.zero?
    total_costs / total_shares
  end

  def last_price
    @last_price ||= price_updates.order('datetime desc').first&.price || 0
  end

  def last_price_timestamp
    @last_price_timestamp ||= price_updates.order('datetime desc').first&.datetime&.to_datetime || DateTime.now
  end

  def last_value
    @last_value ||= total_shares * last_price
  end

  def profit_loss
    @profit_loss ||= last_value - actual_total_costs
  end

  def cash_dividends_total
    cash_dividends.pluck(:amount).sum
  end

  def cash_dividends_annual_dps
    cash_dividends_average_dps * cash_dividends_count_in_a_year
  end

  def history
    @history ||= (activities + stock_dividends + cash_dividends).sort_by do |thing|
      if thing.is_a?(Activity)
        thing.date
      else
        (thing.ex_date.blank? ? thing.pay_date : thing.ex_date)
      end
    end
  end

  def final_profit_loss
    cash_dividends_total + profit_loss
  end

  def profit_loss_percent
    profit_loss / actual_total_costs
  end

  def can_update_from_pse?
    !pse_company_id.blank? && !pse_security_id.blank?
  end

  def pse_url
    return "" if pse_company_id.blank?
    "https://edge.pse.com.ph/companyPage/stockData.do?cmpy_id=#{pse_company_id}"
  end

  protected

  def cash_dividends_average_dps
    return 0 if cash_dividends.length.zero?

    dividends = cash_dividends.collect(&:dividend_per_share).collect(&:to_f).reject(&:zero?)
    @cash_dividends_average_dps ||= (dividends.sum / dividends.length)
  end

  def cash_dividends_count_in_a_year
    return 0 if cash_dividends.length.zero?

    count = cash_dividends.collect(&:pay_date).group_by(&:year).collect { |_year, arr| arr.count }
    @cash_dividends_count_in_a_year ||= (count.sum.to_f / count.length).round(0)
  end

  def stock_dividend_shares
    stock_dividends.pluck(:amount).sum
  end

  def bought_shares
    activities_calculator.bought_shares
  end

  def sold_shares
    activities_calculator.sold_shares
  end

  def buy_costs
    activities_calculator.buy_costs
  end

  def sell_gains
    activities_calculator.sell_gains
  end

  def activities_calculator
    @activities_calculator ||= ActivitiesCalculator.new(activities)
  end
end
