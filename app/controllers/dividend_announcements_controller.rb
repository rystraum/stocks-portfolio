# app/controllers/dividend_announcements_controller.rb

class DividendAnnouncementsController < ApplicationController
  def index
    params[:future_only] ||= '1'
    params[:company_scope] ||= 'portfolio'

    @dividend_announcements = DividendAnnouncement.includes(:company)
                                                  .order(ex_date: :asc)
                                                  .paginate(page: params[:page], per_page: 20)

    if params[:future_only].to_i == 1
      @dividend_announcements = @dividend_announcements.where(
        'ex_date >= ?', Date.today
      )
    end

    if params[:company_scope] == 'portfolio'
      @dividend_announcements = @dividend_announcements.where(company_id: current_user.company_ids)
    end

    return unless params[:ticker].present?

    @dividend_announcements = @dividend_announcements.where(companies: { ticker: params[:ticker] })
  end
end
