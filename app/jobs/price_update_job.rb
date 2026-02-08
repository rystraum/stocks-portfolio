# frozen_string_literal: true

# TODO: Rename from PriceUpdateJob to more generic scraping

class PriceUpdateJob < ApplicationJob
  queue_as :default

  def perform(company)
    pse = PSE.new(company)
    pse.price_update!
    pse.dividend_announcements!
  end
end
