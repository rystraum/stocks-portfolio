# frozen_string_literal: true

namespace :prices do
  desc "Backfill missing daily prices from PSE chart history. Optional: START=YYYY-MM-DD END=YYYY-MM-DD TICKER=ABC PAUSE=30"
  task backfill: :environment do
    companies = Company.alphabetical
    companies = companies.where(ticker: ENV["TICKER"]) if ENV["TICKER"].present?

    companies.each do |company|
      next unless company.can_update_from_pse?

      start_date = ENV["START"].presence&.to_date || 1.year.ago.to_date
      end_date = ENV["END"].presence&.to_date || Time.zone.today
      next if start_date >= end_date

      begin
        created = PSE.new(company).backfill_history!(start_date, end_date)
        Rails.logger.info "[prices:backfill] #{company.ticker}: created #{created} rows (#{start_date}..#{end_date})"
      rescue StandardError => e
        Rails.logger.error "[prices:backfill] #{company.ticker} failed: #{e.message}"
      end

      sleep (ENV["PAUSE"] || 30).to_i
    end
  end
end
