# frozen_string_literal: true

class PriceUpdateCompanies
  def initialize(companies = Company.alphabetical)
    @companies = companies
  end

  def run!
    c = 0

    @companies.each.with_index do |company, index|
      next if !company.can_update_from_pse?
      PriceUpdateJob.set(wait: 2.seconds * index).perform_later(company)
      c += 1
    end

    return c
  end


  def run_from_console
    @companies.to_a.shuffle.each do |company|
      next if !company.can_update_from_pse?

      puts "[#{DateTime.now}] == #{company.ticker} Starting update"
      begin
        pse = PSE.new(company)
        puts "[#{DateTime.now}] == #{company.ticker} Updating price.."
        pse.price_update!
        puts "[#{DateTime.now}] == #{company.ticker} Checking dividend announcements.."
        pse.dividend_announcements!
      rescue StandardError => e
        puts "[#{DateTime.now}] == Failed price update for #{company.ticker} with error #{e.message}"
      end
      puts "[#{DateTime.now}] == #{company.ticker} finished"

      sleep_seconds = rand(60).seconds + 120.seconds
      puts "[#{DateTime.now}] == Sleeping for #{sleep_seconds} seconds \n\n\n"

      sleep(sleep_seconds)
    end
  end
end
