# frozen_string_literal: true

class UserPortfolioCompany
  attr_reader :user, :company

  def initialize(user, company)
    @user = user
    @company = company
  end

  delegate :target_buy_price, to: :@company

  def history
    @history ||= (activities + stock_dividends + cash_dividends).sort_by do |thing|
      if thing.is_a?(Activity)
        thing.date
      else
        thing.ex_date.presence || thing.pay_date
      end
    end
  end

  def dividends
    (stock_dividends + cash_dividends).sort_by(&:pay_date)
  end

  def total_costs
    return 0 if total_shares.zero?

    actual_total_costs
  end

  def actual_total_costs
    @actual_total_costs ||= activities_calculator.buy_costs - activities_calculator.sell_gains
  end

  def last_value
    @last_value ||= total_shares * last_price
  end

  def cash_dividends_total
    cash_dividends.pluck(:amount).sum
  end

  def total_shares
    @total_shares ||= activities_calculator.ending_shares
  end

  def cps
    return 0 if total_costs.zero?

    total_costs / total_shares
  end

  def profit_loss
    @profit_loss ||= last_value - actual_total_costs
  end

  def final_profit_loss
    cash_dividends_total + profit_loss
  end

  def profit_loss_percent
    return 0.0 if actual_total_costs.zero?

    profit_loss / actual_total_costs
  end

  def cash_dividends_annual_dps
    cash_dividends_average_dps * cash_dividends_count_in_a_year
  end

  def cash_dividends_percent_of_total_costs
    return 0.0 if total_costs.zero?

    cash_dividends_total / total_costs.to_f
  end

  def final_profit_loss_percent_of_total_costs
    return 0.0 if total_costs.zero?

    final_profit_loss / total_costs.to_f
  end

  def last_price
    @last_price ||= company.last_price
  end

  private

  def activities
    @activities ||= company.activities.where(user_id: user.id)
  end

  def stock_dividends
    @stock_dividends ||= company.stock_dividends.where(user_id: user.id)
  end

  def cash_dividends
    @cash_dividends ||= company.cash_dividends.where(user_id: user.id)
  end

  def activities_calculator
    @activities_calculator ||= ActivitiesCalculator.new(activities)
  end

  def cash_dividends_average_dps
    return 0 if cash_dividends.empty?

    dividends = cash_dividends.collect(&:dividend_per_share).collect(&:to_f).reject(&:zero?)
    @cash_dividends_average_dps ||= (dividends.sum / dividends.length)
  end

  def cash_dividends_count_in_a_year
    return 0 if cash_dividends.empty?

    count = cash_dividends.collect(&:pay_date).group_by(&:year).collect { |_year, arr| arr.count }
    @cash_dividends_count_in_a_year ||= (count.sum.to_f / count.length).round(0)
  end
end
