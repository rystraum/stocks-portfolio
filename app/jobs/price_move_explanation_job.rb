# frozen_string_literal: true

class PriceMoveExplanationJob < ApplicationJob
  queue_as :default

  def perform(company, range_days, force = false) # rubocop:disable Style/OptionalBooleanParameter
    Rails.logger.info "Explaining price moves for #{company.ticker} (#{range_days} days, force: #{force})..."
    PriceMoveExplainer.new(company, range_days: range_days, force: force).run!
  rescue StandardError => e
    Rails.logger.error "PriceMoveExplanationJob failed for #{company.ticker}: #{e.message}"
  end
end
