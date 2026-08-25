# frozen_string_literal: true

class PriceMoveExplainer
  def initialize(company, range_days: 90, force: false, detector: nil, client: nil)
    @company = company
    @range_days = range_days
    @force = force
    @detector = detector || PriceMoveDetector.new(company, range_days: range_days)
    @client = client || GeminiClient.new
  end

  def run!
    key_dates = @detector.key_dates
    if key_dates.empty?
      Rails.logger.info "PriceMoveExplainer: no key dates for #{@company.ticker} in the last #{@range_days} days"
      return
    end

    uncached_key_dates(key_dates).each do |key_date|
      explain(key_date)
    rescue StandardError => e
      Rails.logger.error "PriceMoveExplainer: failed for #{@company.ticker} on #{key_date[:date]}: #{e.message}"
    end
  end

  private

  def uncached_key_dates(key_dates)
    cached = @company.price_move_insights.where(move_date: key_dates.map { _1[:date] })
    if @force
      cached.delete_all
      return key_dates
    end

    key_dates.reject { |key_date| cached.any? { |insight| insight.move_date == key_date[:date] } }
  end

  def explain(key_date)
    result = @client.grounded_search(prompt_for(key_date))

    insight = @company.price_move_insights.find_or_initialize_by(move_date: key_date[:date])
    insight.update!(
      pct_change: key_date[:pct_change],
      close_price: key_date[:close_price],
      range_days: @range_days,
      explanation: result[:text],
      news_items: result[:citations],
      search_queries: result[:queries],
    )
  end

  def prompt_for(key_date)
    "On #{key_date[:date]}, #{@company.name} (#{@company.ticker}) on the Philippine Stock Exchange closed at " \
      "#{key_date[:close_price]} PHP, #{key_date[:pct_change].round(2)}% versus the previous trading day. " \
      "Search for news and official PSE Edge disclosures around that date and explain the price move in 2-3 sentences. " \
      "If you find no relevant news, say so."
  end
end
