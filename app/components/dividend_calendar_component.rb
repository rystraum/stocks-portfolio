class DividendCalendarComponent < ViewComponent::Base
  def initialize(companies:, set:, year:, costs_calculator:)
    @companies = companies
    @costs_calculator = costs_calculator
    @set = set
    @year = year.to_s
    @dividends_this_year = @set.sums[@year] || 0
    @costs_this_year = costs_calculator.costs_as_of(year: year.to_i, month: 12)
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
end