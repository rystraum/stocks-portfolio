# frozen_string_literal: true

class CompaniesTool < ApplicationTool
  description 'Get companies'

  arguments do
    # required(:ticker).filled(:string).description('ticker of the company to get transactions for')
    # optional(:prefix).filled(:string).description('Prefix to add to the greeting')
  end

  def call
    current_user = User.last
    company_set = CompanySet.new(
      UserPortfolio.new(current_user).company_ids,
      current_user
    )
    company_set.companies.to_json
  end
end
