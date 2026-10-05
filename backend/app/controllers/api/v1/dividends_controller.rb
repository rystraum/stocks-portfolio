# frozen_string_literal: true

class Api::V1::DividendsController < Api::V1::BaseController
  def index
    if params[:year].present?
      year = params[:year].to_i
      months = dividend_months_for(year)
      return render json: { year:, months:, total: round2(months.sum { |m| m[:total].to_f }) }
    end

    first_year = CashDividend.where(user_id: current_user.id).minimum(:pay_date)&.year || Date.current.year
    current_year = Date.current.year
    years = {}
    (first_year..current_year).each do |year|
      months = dividend_months_for(year)
      years[year.to_s] = months
    end

    render json: { years:, years_list: years.keys.map(&:to_i) }
  end
end
