class PriceUpdateJob < ApplicationJob
  queue_as :default

  def perform(company)
    PSE.new(company).price_update!
  end
end
