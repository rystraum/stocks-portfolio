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
    # Aggregate to daily bars: one candle per date (open = first update of the
    # day, close = last, high/low = extremes). Multiple updates on the same date
    # would otherwise produce duplicate dates, which the frontend candlestick
    # chart cannot render.
    points = company.price_updates
                 .where.not(price: nil)
                 .where.not(open: nil)
                 .where.not(high: nil)
                 .where.not(low: nil)
                 .order(datetime: :asc)
                 .group_by { |u| u.datetime.to_date }
                 .to_a
                 .last(days)
                 .map do |date, rows|
                   {
                     time: date,
                     open: rows.first.open.to_f,
                     high: rows.map { |r| r.high.to_f }.max,
                     low: rows.map { |r| r.low.to_f }.min,
                     close: rows.last.price.to_f
                   }
                 end

    render json: { ticker: company.ticker, days:, points: }
  end
end
