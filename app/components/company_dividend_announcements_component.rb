# frozen_string_literal: true

class CompanyDividendAnnouncementsComponent < ViewComponent::Base
  attr_accessor :announcements, :last_price

  def initialize(user:, company:)
    super
    @user = user
    @company = company
    @announcements = DividendAnnouncement.where(company_id: company.id).in_the_future
    @last_price = company.last_price
  end
end
