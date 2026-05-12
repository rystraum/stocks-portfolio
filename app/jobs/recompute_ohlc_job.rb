# frozen_string_literal: true

class RecomputeOhlcJob < ApplicationJob
  queue_as :default

  def perform(company = nil)
    if company.present?
      Rails.logger.info "Recomputing OHLC for #{company.ticker} from notes..."
      PriceUpdate.missing_ohlc.where(company: company).where.not(notes: [nil, ""]).find_each do |update|
        values = PSE.extract_ohlc_from_html(update.notes)
        next if values.nil?
        next if values[:open].blank? && values[:high].blank? && values[:low].blank?

        # rubocop:disable Rails/SkipsModelValidations
        update.update_columns(open: values[:open], high: values[:high], low: values[:low])
        # rubocop:enable Rails/SkipsModelValidations
      end
      remaining = PriceUpdate.missing_ohlc.where(company: company).count
      Rails.logger.info "Recompute OHLC for #{company.ticker} complete. #{remaining} records still missing."
    else
      PriceUpdate.recompute_from_notes!
    end
  end
end
