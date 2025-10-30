# frozen_string_literal: true

class CompanyResource < ApplicationResource
  uri 'entities/companies'
  resource_name 'Companies'
  description 'Companies in the current user portfolio'
  mime_type 'application/json'

  def content(params = {})
    current_user = User.last
    company_set = CompanySet.new(
      UserPortfolio.new(current_user).company_ids,
      current_user
    )
    JSON.generate(company_set.companies.to_json)
  end
end
