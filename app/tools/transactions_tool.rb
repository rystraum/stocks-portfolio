# frozen_string_literal: true

class TransactionsTool < ApplicationTool
  description 'Get transactions history of a company'

  arguments do
    required(:ticker).filled(:string).description('ticker of the company to get transactions for')
    # optional(:prefix).filled(:string).description('Prefix to add to the greeting')
  end

  def call(ticker:)
    current_user = User.last
    company_set = CompanySet.new(
      UserPortfolio.new(current_user).companies,
      current_user
    )
    company = company_set.companies.find { |company| company.ticker == ticker.upcase }
    company_set.get_portfolio(company).history.collect(&:to_json)
  end
end
