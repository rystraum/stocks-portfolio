# frozen_string_literal: true

class DividendMonthComponent < ViewComponent::Base
  def initialize(companies:, set:, year:, month:)
    @companies = companies
    @set = set
    @year = year.to_s
    @month = month.to_s
  end

  def breakdown
    @set.breakdown[@year][@month] || {}
  rescue StandardError
    {}
  end

  def total_count_this_month
    (breakdown.keys || []).count
  end

  def total_amount_this_month
    helpers.format_currency(@set.amounts.dig(@year, @month) || 0)
  end

  def month_name
    Date::MONTHNAMES[@month.to_i]
  end
end
