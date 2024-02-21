class DashboardController < ApplicationController
  before_action :authenticate_user!

  def show
    company_set = CompanySet.new(
      UserPortfolio.new(current_user).companies,
      current_user
    )
    if params[:sort_by]
      company_set.sort_by = params[:sort_by]
    end
    render "show", locals: { company_set: company_set }
  end

  def update_prices
    portfolio_companies = UserPortfolio.new(current_user).companies
    update_results = portfolio_companies.collect.with_index do |company, index|
      next if !company.can_update_from_pse?
      PriceUpdateJob.set(wait: 2.seconds * index).perform_later(company)
    rescue RuntimeError
      false
    end

    # message = if update_results.all?
    #   "All portfolio company prices updated"
    # else
    #   "Some portfolio company prices failed to update"
    # end

    redirect_back(fallback_location: root_path, alert: "Update is being done in the background. Check back after a couple of minutes.")
  end
end