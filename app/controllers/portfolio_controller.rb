require 'ostruct'

class PortfolioController < AuthenticatedUserController
  def home
    companies = UserPortfolio.new(current_user).companies
    company_set = CompanySet.new(companies, current_user)

    @cash_data = PortfolioItem.new(spent: 0, current_value: 0)
    @uitf_data = PortfolioItem.new(spent: 0, current_value: 0)
    @stock_data = PortfolioItem.new(spent: company_set.total_costs, current_value: company_set.total_value)
    @crypto_data = PortfolioItem.new(spent: 0, current_value: 0)
  end
end