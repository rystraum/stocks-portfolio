class DividendLadderComponent < ViewComponent::Base
  def initialize(set:, year:, costs_calculator:)
    @costs_calculator = costs_calculator
    @set = set
    @year = year.to_s
    @costs_this_year = costs_calculator.costs_as_of(year: year.to_i, month: 12)
  end

  def total_this_year
    helpers.format_currency @set.sums[@year]
  end

  def formatted_costs_this_year
    helpers.format_currency @costs_this_year
  end

  def percent_dividends_this_year
    helpers.format_percentage(@set.sums[@year], @costs_this_year)
  end
end