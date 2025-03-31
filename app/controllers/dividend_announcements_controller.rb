# app/controllers/dividend_announcements_controller.rb

class DividendAnnouncementsController < ApplicationController
  def index
    params[:future_only] ||= '1'
    params[:company_scope] ||= 'portfolio'

    @dividend_announcements = DividendAnnouncement.includes(:company)
                                                  .order(payout_date: :asc, company_id: :asc)

    if params[:future_only].to_i == 1
      @dividend_announcements = @dividend_announcements.in_the_future
    end

    if params[:future_only].to_i == 2
      @dividend_announcements = @dividend_announcements.ex_date_in_the_future
    end

    if params[:future_only].to_i == 3
      @dividend_announcements = @dividend_announcements.within_the_year
    end

    if params[:company_scope] == 'portfolio'
      @dividend_announcements = @dividend_announcements.where(company_id: current_user.company_ids)
    else
      @dividend_announcements = @dividend_announcements.paginate(page: params[:page], per_page: 50)
    end

    return unless params[:ticker].present?

    @dividend_announcements = @dividend_announcements.where(companies: { ticker: params[:ticker] })
  end
end
