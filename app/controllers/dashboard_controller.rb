class DashboardController < ApplicationController
  before_action :authenticate_user!

  def show
    company_set = CompanySet.new(UserPortfolio.new(current_user).companies)
    render "show", locals: { company_set: company_set }
  end

  def update_prices
    portfolio_companies = UserPortfolio.new(current_user).companies
    update_results = portfolio_companies.collect do |company|
      PSE.new(company).price_update!&.persisted?
    rescue RuntimeError
      false
    end

    message = if update_results.all?
      "All portfolio company prices updated"
    else
      "Some portfolio company prices failed to update"
    end

    redirect_back(fallback_location: root_path, alert: message)
  end
end