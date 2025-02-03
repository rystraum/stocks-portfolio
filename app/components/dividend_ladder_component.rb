class DividendLadderComponent < ViewComponent::Base
  def initialize(set:, year:, costs_calculator:)
    @costs_calculator = costs_calculator
    @set = set
    @year = year.to_s
    @dividends_this_year = @set.sums[@year] || 0
    @costs_this_year = costs_calculator.costs_as_of(year: year.to_i, month: 12)
    @costs_last_year = costs_calculator.costs_as_of(year: year.to_i - 1, month: 12)
  end

  def average_monthly_dividends
    helpers.format_currency(@dividends_this_year / 12)
  end

  def total_this_year
    helpers.format_currency @dividends_this_year
  end

  def formatted_costs_this_year
    helpers.format_currency @costs_this_year
  end

  def percent_dividends_this_year
    helpers.format_percentage(@dividends_this_year, @costs_this_year)
  end

  def net_yoy_costs_change
    helpers.format_currency(@costs_this_year - @costs_last_year)
  end

  def percent_dividends_yoy_costs_change
    helpers.format_percentage(@dividends_this_year, @costs_this_year - @costs_last_year)
  end

  def yoy_costs_change_less_dividends
    helpers.format_currency(@costs_this_year - @costs_last_year - @dividends_this_year)
  end
end
