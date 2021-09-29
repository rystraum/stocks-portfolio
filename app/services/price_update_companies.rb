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
    @companies.each.with_index do |company, index|
      next if !company.can_update_from_pse?      
      PSE.new(company).price_update!
      sleep(2.seconds * index)
    end
  end
end