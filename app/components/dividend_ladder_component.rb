class DividendLadderComponent < ViewComponent::Base
  def initialize(set:, year:)
    @set = set
    @year = year.to_s
  end

  def total_this_year
    helpers.format_currency @set.sums[@year]
  end
end