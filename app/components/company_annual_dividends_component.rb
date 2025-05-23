# frozen_string_literal: true

class CompanyAnnualDividendsComponent < ViewComponent::Base
  def initialize(user:, company:)
    super
    @user = user
    @dividends = user.cash_dividends_with_price(company)
    @portfolio = UserPortfolioCompany.new(user, company)
    @dividend_years = @dividends.group_by { |d| d.pay_date.year }.sort
  end

  # rubocop:disable Metrics/MethodLength
  def years
    @dividend_years.collect do |year, dividends|
      total = dividends.sum(&:amount)
      per_share = dividends.sum { |d| d.dividend_per_share.to_f }
      last_price = dividends.last.last_price&.price
      {
        year: year,
        dividends: dividends,
        total: total,
        per_share: per_share,
        cps: @portfolio.cps, # FIXME: This should be the CPS during that year, and not overall CPS
        last_price: last_price
      }
    end
  end
  # rubocop:enable Metrics/MethodLength
end
