# app/controllers/dividend_announcements_controller.rb

class DividendAnnouncementsController < AuthenticatedUserController
  def index
    params[:future_only] ||= '1'
    params[:company_scope] ||= 'portfolio'

    @dividend_announcements = DividendAnnouncement.includes(:company)
                                                  .order(payout_date: :asc, company_id: :asc)

    @converted_announcements = current_user.converted_announcements

    @dividend_announcements = @dividend_announcements.in_the_future if params[:future_only].to_i == 1

    @dividend_announcements = @dividend_announcements.ex_date_in_the_future if params[:future_only].to_i == 2

    @dividend_announcements = @dividend_announcements.within_the_year if params[:future_only].to_i == 3

    @dividend_announcements = if params[:company_scope] == 'portfolio'
                                @dividend_announcements.where(company_id: current_user.company_ids)
                              else
                                @dividend_announcements.paginate(page: params[:page], per_page: 50)
                              end

    return unless params[:ticker].present?

    @dividend_announcements = @dividend_announcements.where(companies: { ticker: params[:ticker] })
  end

  def create_transaction
    dividend_announcement = DividendAnnouncement.find(params[:id])

    if dividend_announcement.blank?
      return redirect_back(fallback_location: dividend_announcements_path,
                           alert: 'Dividend announcement not found',)
    end

    service = ConvertDividendAnnouncement.new(dividend_announcement, current_user)
    success, message = service.call

    return redirect_back(fallback_location: dividend_announcements_path, notice: message) if success

    return redirect_back(fallback_location: dividend_announcements_path, alert: message)
  end
end
