# frozen_string_literal: true

class CompanySet
  attr_reader :user, :portfolio
  attr_accessor :sort_by

  def initialize(companies, user)
    @companies = companies
    @user = user
    @portfolio = {}
    @sort_by = "default"

    @companies.each do |company|
      @portfolio[company.id] = UserPortfolioCompany.new(user, company)
    end
  end

  def companies
    if @sort_by == "dividends_percent"
      @companies.sort_by { |c| [c.inactive ? 1 : 0, get_portfolio(c).total_shares.zero? ? 1 : 0, (1 - get_portfolio(c).cash_dividends_percent_of_total_costs)] }
    elsif @sort_by == "final_pl_percent"
      @companies.sort_by { |c| [c.inactive ? 1 : 0, get_portfolio(c).total_shares.zero? ? 1 : 0, (1 - get_portfolio(c).final_profit_loss_percent_of_total_costs)] }
    elsif @sort_by == "cost"
      @companies.sort_by { |c| [c.inactive ? 1 : 0, get_portfolio(c).total_shares.zero? ? 1 : 0, (1 - get_portfolio(c).total_costs)] }
    else
      @companies.sort_by { |c| [c.inactive ? 1 : 0, get_portfolio(c).total_shares.zero? ? 1 : 0, c.ticker] }
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
    @total_profit_loss ||= companies.collect { |company| get_portfolio(company).profit_loss }.sum
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

  def to_json
    {
      totals: {
        total_costs: total_costs,
        actual_total_costs: actual_total_costs,
        total_value: total_value,
        total_profit_loss: total_profit_loss,
        total_dividends: total_dividends,
        final_profit_loss: final_profit_loss,
      },
      # companies: companies,
      # last_prices: companies.each_with_object({}) { |company, last_prices| last_prices[company.id.to_s] = get_portfolio(company).last_price },
      # history: companies.each_with_object({}) { |company, history| history[company.id.to_s] = get_portfolio(company).history },
    }
  end
end
