# frozen_string_literal: true

class CompanyDividendAnnouncementsComponent < ViewComponent::Base
  attr_accessor :announcements, :last_price, :company, :cps

  def initialize(user:, company:)
    super
    @user = user
    @company = company
    @announcements = DividendAnnouncement.where(company_id: company.id).in_the_future
    @cps = UserPortfolioCompany.new(user, company).cps
    @last_price = company.last_price
  end
end
