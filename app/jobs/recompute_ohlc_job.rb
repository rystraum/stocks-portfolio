# frozen_string_literal: true

class RecomputeOhlcJob < ApplicationJob
  queue_as :default

  def perform(company = nil)
    if company.present?
      Rails.logger.info "Recomputing OHLC for #{company.ticker} from PSE history..."
      PriceUpdate.recompute_company_from_history!(company)
      remaining = PriceUpdate.missing_ohlc.where(company: company).count
      Rails.logger.info "Recompute OHLC for #{company.ticker} complete. #{remaining} records still missing."
    else
      PriceUpdate.recompute!
    end
  end
end
