# frozen_string_literal: true

class PriceMoveDetector
  def initialize(company, range_days: 90)
    @company = company
    @range_days = range_days
  end

  def key_dates(limit: 5, min_pct: 3.0)
    moves = daily_closes.each_cons(2).filter_map do |(_prev_date, prev_close), (date, close)|
      next if prev_close.nil? || prev_close.zero?

      pct_change = ((close - prev_close) / prev_close) * 100
      next if pct_change.abs < min_pct

      { date: date, pct_change: pct_change, close_price: close }
    end

    moves.sort_by { |move| -move[:pct_change].abs }.first(limit)
  end

  private

  attr_reader :company, :range_days

  # Keeps the last row per calendar date, deduping scraped intraday rows
  # against backfilled midnight rows for the same trading day.
  def daily_closes
    @daily_closes ||= company.price_updates
                             .where(datetime: range_days.days.ago..)
                             .order(:datetime)
                             .each_with_object({}) { |update, closes| closes[update.datetime.to_date] = update.price }
                             .to_a
  end
end
