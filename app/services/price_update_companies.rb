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
    @companies.to_a.shuffle.each.with_index(1) do |company, index|
      next if !company.can_update_from_pse?      
      puts "== #{company.ticker} Starting price update"
      begin
        pse = PSE.new(company)
        pse.price_update!
        pse.dividend_announcements!
      rescue Exception => e
        puts "Failed price update for #{company.ticker} with error #{e.message}"
      end
      puts "== #{company.ticker} finished \n\n\n"
      wait_time = index < 30 ? index : 30
      sleep(wait_time.seconds)
    end
  end
end
