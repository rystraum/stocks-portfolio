# frozen_string_literal: true

class CompanyDividendAnnouncementsComponent < ViewComponent::Base
  attr_accessor :announcements, :last_price, :company, :cps

  def initialize(user:, company:)
    super
    portfolio = UserPortfolioCompany.new(user, company)
    @user = user
    @company = company
    @announcements = DividendAnnouncement.where(company_id: company.id).in_the_future
    @cps = portfolio.cps
    @shares_today = portfolio.total_shares
    @last_price = company.last_price
    @dividend_frequency_months = company.dividend_frequency_months || 12
    @expected_number_of_months_with_dividends = @dividend_frequency_months ? 12.0 / @dividend_frequency_months : 1.0
  end
end
