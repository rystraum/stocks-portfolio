# frozen_string_literal: true

class CompanySet
  attr_accessor :companies
  def initialize(companies)
    @companies = companies.sort_by { |c| [c.inactive ? 1 : 0, c.ticker] }
  end

  def total_costs
    @total_costs ||= companies.collect(&:total_costs).sum
  end

  def actual_total_costs
    @total_costs ||= companies.collect(&:actual_total_costs).sum
  end

  def total_value
    @total_value ||= companies.collect(&:last_value).sum
  end

  def total_profit_loss
    total_value - actual_total_costs
  end

  def total_dividends
    @total_dividends ||= companies.collect(&:cash_dividends_total).sum
  end

  def final_profit_loss
    total_profit_loss + total_dividends
  end
end
