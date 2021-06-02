# frozen_string_literal: true

class CompanyAnnualSummary
  attr_accessor :year, :company
  def initialize(company, year)
    @company = company
    @year = year
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

  private

  def activities
    company.activities.where(date: Date.new(year, 1, 1)..Date.new(year, 12, 31))
  end

  def activities_calculator
    @activities_calculator ||= ActivitiesCalculator.new(activities)
  end
end
