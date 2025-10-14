# frozen_string_literal: true

class PortfolioController < AuthenticatedUserController
  def home
    companies = UserPortfolio.new(current_user).companies
    company_set = CompanySet.new(companies, current_user)

    @cash_data = PortfolioItem.new(spent: 0, current_value: 0)
    @uitf_data = PortfolioItem.new(spent: 0, current_value: 0)
    @stock_data = PortfolioItem.new(spent: company_set.total_costs, current_value: company_set.total_value)
    @crypto_data = PortfolioItem.new(spent: 0, current_value: 0)
  end

  def stocks
    company_set = CompanySet.new(
      UserPortfolio.new(current_user).companies,
      current_user,
    )

    if params[:sort_by]
      company_set.sort_by = params[:sort_by]
    end

    respond_to do |format|
      format.html { render 'stocks', locals: { company_set: company_set } }
      format.json { render json: company_set.to_json }
    end
  end
end
