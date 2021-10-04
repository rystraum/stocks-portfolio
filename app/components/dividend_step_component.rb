class DividendStepComponent < ViewComponent::Base
  def initialize(set:, year:, month:)
    @set = set
    @year = year.to_s
    @month = month.to_s
  end

  def breakdown
    @set.breakdown[@year][@month].to_a.sort rescue []
  end

  def total_count_this_month
    breakdown.count
  end

  def total_amount_this_month
    helpers.format_currency(@set.amounts.dig(@year, @month) || 0)
  end

  def month_name
    Date::MONTHNAMES[@month.to_i]
  end
end