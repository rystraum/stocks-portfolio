# frozen_string_literal: true

class CompanySet
  attr_accessor :companies, :user, :portfolio
  def initialize(companies, user)
    @companies = companies.sort_by { |c| [c.inactive ? 1 : 0, c.ticker] }
    @user = user
    @portfolio = {}
    
    @companies.each do |company|
      @portfolio[company.id] = UserPortfolioCompany.new(user, company)
    end
  end

  def total_costs
    @total_costs ||= companies.collect { |company| get_portfolio(company).total_costs }.sum
  end

  def actual_total_costs
    @total_costs ||= companies.collect { |company| get_portfolio(company).actual_total_costs }.sum
  end

  def total_value
    @total_value ||= companies.collect { |company| get_portfolio(company).last_value }.sum
  end

  def total_profit_loss
    total_value - actual_total_costs
  end

  def total_dividends
    @total_dividends ||= companies.collect { |company| get_portfolio(company).cash_dividends_total }.sum
  end

  def final_profit_loss
    total_profit_loss + total_dividends
  end

  def get_portfolio(company)
    portfolio[company.id]
  end
end
