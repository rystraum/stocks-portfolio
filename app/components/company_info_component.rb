class CompanyInfoComponent < ViewComponent::Base
  attr_reader :company

  def initialize(company)
    @company = company
  end

  def with_company_name?
    !@company.name.blank?
  end

  def simply_wall_st_url
    return "" if !with_company_name?
    "https://simplywall.st/stocks/ph/#{@company.industry.parameterize.downcase}/pse-#{@company.ticker.downcase}/#{@company.name.parameterize}-shares"
  end

  def marketwatch_url
    "https://www.marketwatch.com/investing/stock/#{@company.ticker}?countrycode=ph"
  end
end
