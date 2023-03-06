class CompanyInfoComponent < ViewComponent::Base
  attr_reader :company
  def initialize(company)
    @company = company
  end

  def simply_wall_st_url
    "https://simplywall.st/stocks/ph/media/pse-#{@company.ticker}/#{@company.company_name.parameterize}-shares"
  end
end