# app/controllers/dividend_announcements_controller.rb

class DividendAnnouncementsController < ApplicationController
  def index
    params[:future_only] ||= '1'

    @dividend_announcements = DividendAnnouncement.includes(:company)
                                                  .order(ex_date: :asc)
                                                  .paginate(page: params[:page], per_page: 20)

    @dividend_announcements.where('ex_date >= ?', Date.today) if params[:future_only].to_i == 1

    return unless params[:ticker].present?

    @dividend_announcements = @dividend_announcements.where(companies: { ticker: params[:ticker] })
  end
end
