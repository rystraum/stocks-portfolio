# frozen_string_literal: true

class PriceUpdate < ApplicationRecord
  belongs_to :company

  scope :latest_first, -> { order("datetime desc") }
  scope :missing_ohlc, -> { where(open: nil).or(where(high: nil)).or(where(low: nil)) }

  def to_formatted_s
    "#{price} @ #{datetime.to_formatted_s :long}"
  end

  def self.recompute!(batch_size: 1000, pause_seconds: 30)
    loop do
      batch = missing_ohlc.order(datetime: :desc).limit(batch_size).includes(:company)
      break if batch.empty?

      batch.group_by(&:company).each do |company, updates|
        recompute_company_ohlc!(company, updates)
      end

      remaining = missing_ohlc.count
      Rails.logger.info "Recompute OHLC: #{remaining} records remaining"
      break if remaining.zero?

      sleep(pause_seconds)
    end
  end

  def self.recompute_company_from_history!(company, days: 365)
    return unless company.can_update_from_pse?

    updates = missing_ohlc.where(company: company)
                          .where("datetime >= ?", days.days.ago)
                          .order(datetime: :asc)
    return if updates.empty?

    dates = updates.map { |u| u.datetime.to_date }
    history = PSE.new(company).fetch_history_ohlc(dates.min, dates.max)

    updates.each do |update|
      match = history.find { |h| Date.parse(h["CHART_DATE"]) == update.datetime.to_date }
      next unless match

      # rubocop:disable Rails/SkipsModelValidations
      update.update_columns(
        open: match["OPEN"],
        high: match["HIGH"],
        low: match["LOW"],
      )
      # rubocop:enable Rails/SkipsModelValidations
    end
  rescue StandardError => e
    Rails.logger.error "Failed to recompute OHLC from history for #{company.ticker}: #{e.message}"
  end

  def self.recompute_company_ohlc!(company, updates)
    return unless company.can_update_from_pse?

    dates = updates.map { |u| u.datetime.to_date }
    history = PSE.new(company).fetch_history_ohlc(dates.min, dates.max)

    updates.each do |update|
      match = history.find { |h| Date.parse(h["CHART_DATE"]) == update.datetime.to_date }
      next unless match

      # rubocop:disable Rails/SkipsModelValidations
      update.update_columns(
        open: match["OPEN"],
        high: match["HIGH"],
        low: match["LOW"],
      )
      # rubocop:enable Rails/SkipsModelValidations
    end
  rescue StandardError => e
    Rails.logger.error "Failed to recompute OHLC for #{company.ticker}: #{e.message}"
  end
  private_class_method :recompute_company_ohlc!
end
