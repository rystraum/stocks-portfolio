require 'ostruct'

class PortfolioController < AuthenticatedUserController
  def home
    @cash_data = PortfolioItem.new(spent: 1000.00, current_value: 1200.00)
    @uitf_data = PortfolioItem.new(spent: 500.00, current_value: 500.00)
    @stock_data = PortfolioItem.new(spent: 2500.00, current_value: 3000.00)
    @crypto_data = PortfolioItem.new(spent: 1000.00, current_value: 800.00)
  end
end