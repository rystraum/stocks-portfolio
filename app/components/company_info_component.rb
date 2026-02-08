# frozen_string_literal: true

class CompanyInfoComponent < ViewComponent::Base
  attr_reader :company, :last_price

  def initialize(company, last_price)
    @company = company
    @last_price = last_price
  end

  def with_company_name?
    @company.name.present?
  end

  def simply_wall_st_url
    return company.simply_wall_st_url if company.simply_wall_st_url.present?
    return "" unless with_company_name?

    "https://simplywall.st/stocks/ph/#{@company.industry.parameterize.downcase}/pse-#{@company.ticker.downcase}/#{@company.name.parameterize}-shares"
  end

  def marketwatch_url
    "https://www.marketwatch.com/investing/stock/#{@company.ticker}?countrycode=ph"
  end

  def pesobility_url
    "https://www.pesobility.com/dividends/#{@company.ticker}"
  end
end
