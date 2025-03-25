# app/controllers/dividend_announcements_controller.rb

class DividendAnnouncementsController < ApplicationController
  def index
    @dividend_announcements = DividendAnnouncement.includes(:company)
      .order(ex_date: :asc)
      .paginate(page: params[:page], per_page: 20)

    if params[:ticker].present?
      @dividend_announcements = @dividend_announcements.where(companies: { ticker: params[:ticker] })
    end
  end
end