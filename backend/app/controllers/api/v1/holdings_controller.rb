# frozen_string_literal: true

class Api::V1::HoldingsController < Api::V1::BaseController
  def index
    include_inactive = params.fetch("include_inactive", "true") != "false"
    companies = company_set.companies
    companies = companies.select { |company| holding_payload(company)[:active] } unless include_inactive
    render json: companies.map { |company| holding_payload(company) }
  end

  def show
    company = Company.where("UPPER(ticker) = ?", params[:ticker].to_s.upcase).first
    if company.nil?
      return render json: { error: { code: "not_found", message: "No such ticker" } }, status: :not_found
    end

    base = holding_payload(company)
    render json: base.merge(
      dividends_total: base[:dividends],
      activities: company.activities.where(user_id: current_user.id).order(:date).map do |a|
        {
          date: a.date,
          side: a.activity_type,
          shares: a.number_of_shares,
          price: a.number_of_shares.positive? ? round2(a.total_price / a.number_of_shares) : nil,
          amount: round2(a.total_price),
          charges: round2(a.charges)
        }
      end,
      dividends: company.cash_dividends.where(user_id: current_user.id).order(pay_date: :desc).map do |d|
        { date: d.pay_date, amount: round2(d.amount), pay_date: d.pay_date, ex_date: d.ex_date }
      end
    )
  end

  def price_history
    company = Company.where("UPPER(ticker) = ?", params[:ticker].to_s.upcase).first
    if company.nil?
      return render json: { error: { code: "not_found", message: "No such ticker" } }, status: :not_found
    end

    days = (params[:days] || 365).to_i.clamp(1, 3650)
    points = company.price_updates
                   .where.not(price: nil)
                   .where(open: ..nil).or(company.price_updates.where(open: nil))
                   .order(datetime: :desc)
                   .limit(days)
                   .reverse
                   .map do |p|
                     { time: p.datetime.to_date, open: p.open, high: p.high, low: p.low, close: p.price }
                   end

    render json: { ticker: company.ticker, days:, points: }
  end
end
