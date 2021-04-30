class DashboardController < ApplicationController
  before_action :authenticate_user!

  def show
    company_set = CompanySet.new(UserPortfolio.new(current_user).companies)
    render "show", locals: { company_set: company_set }
  end
end