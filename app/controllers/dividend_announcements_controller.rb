# app/controllers/dividend_announcements_controller.rb

class DividendAnnouncementsController < ApplicationController
  def index
    params[:future_only] ||= '1'
    params[:company_scope] ||= 'portfolio'

    @dividend_announcements = DividendAnnouncement.includes(:company)
                                                  .order(payout_date: :asc, company_id: :asc)

    if params[:future_only].to_i == 1
      @dividend_announcements = @dividend_announcements.where(
        'payout_date >= ?', Date.today
      )
    end

    if params[:future_only].to_i == 2
      @dividend_announcements = @dividend_announcements.where(
        'payout_date >= ? AND payout_date < ?', Date.today.beginning_of_year, Date.today.end_of_year
      )
    end

    if params[:company_scope] == 'portfolio'
      @dividend_announcements = @dividend_announcements.where(company_id: current_user.company_ids)
    else
      @dividend_announcements = @dividend_announcements.paginate(page: params[:page], per_page: 20)
    end

    return unless params[:ticker].present?

    @dividend_announcements = @dividend_announcements.where(companies: { ticker: params[:ticker] })
  end
end
