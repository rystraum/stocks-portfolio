class PriceUpdateCompanies
  def initialize(companies = Company.alphabetical, is_console = false)
    @companies = companies
    @is_console = is_console
  end

  def run!
    c = 0

    @companies.each.with_index do |company, index|
      next if !company.can_update_from_pse?
      
      if is_console
        PSE.new(company).price_update!
        sleep(2.seconds * index)
      else
        PriceUpdateJob.set(wait: 2.seconds * index).perform_later(company)
      end

      c += 1
    end

    return c
  end
end