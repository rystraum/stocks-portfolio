class DashboardController < ApplicationController
  before_action :authenticate_user!

  def show
    company_set = CompanySet.new(Company.all)
    render "show", locals: { company_set: company_set }
  end
end