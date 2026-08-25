# frozen_string_literal: true

class CompanyAnnualSummary
  attr_accessor :year, :company

  def initialize(company, year)
    @company = company
    @year = year
  end

  delegate :bought_shares, to: :activities_calculator

  delegate :sold_shares, to: :activities_calculator

  delegate :buy_costs, to: :activities_calculator

  delegate :sell_gains, to: :activities_calculator

  private

  def activities
    company.activities.where(date: Date.new(year, 1, 1)..Date.new(year, 12, 31))
  end

  def activities_calculator
    @activities_calculator ||= ActivitiesCalculator.new(activities)
  end
end
