# frozen_string_literal: true

class CompaniesController < ApplicationController
  before_action :set_company, only: %i[show edit update destroy last_price price_update_from_pse]

  # GET /companies
  # GET /companies.json
  def index
    @companies = Company.alphabetical
    @company = Company.new
  end

  # GET /companies/1
  # GET /companies/1.json
  def show; end

  def price_update_all_from_pse
    count = PriceUpdateCompanies.new.run!
    respond_to do |format|
      format.html do
        flash[:notice] = "Queued price update for #{count} companies."
        redirect_back(fallback_location: companies_url)
      end
    end
  end

  def price_update_from_pse
    price_update = PSE.new(@company).price_update!

    redirect_back(fallback_location: @company, alert: "Price update failed.") and return unless price_update.persisted?

    respond_to do |format|
      format.html do
        flash[:notice] = "Succeeded with price update from PSE of #{@company.ticker}."
        redirect_back(fallback_location: @company)
      end
      format.json { render json: { price_update: price_update } }
    end
  end

  def last_price
    respond_to do |format|
      format.html
      format.json { render json: { lastPrice: @company.last_price } }
    end
  end

  # GET /companies/new
  def new
    @company = Company.new
  end

  # GET /companies/1/edit
  def edit; end

  # POST /companies
  # POST /companies.json
  def create
    @company = Company.new(company_params)

    respond_to do |format|
      if @company.save
        format.html { redirect_to @company, notice: 'Company was successfully created.' }
        format.json { render :show, status: :created, location: @company }
      else
        format.html { render :new }
        format.json { render json: @company.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /companies/1
  # PATCH/PUT /companies/1.json
  def update
    respond_to do |format|
      if @company.update(company_params)
        format.html { redirect_to @company, notice: 'Company was successfully updated.' }
        format.json { render :show, status: :ok, location: @company }
      else
        format.html { render :edit }
        format.json { render json: @company.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /companies/1
  # DELETE /companies/1.json
  def destroy
    @company.destroy
    respond_to do |format|
      format.html { redirect_to companies_url, notice: 'Company was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_company
    @company = Company.find_by(id: params[:id]) || Company.find_by(ticker: params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def company_params
    params.require(:company).permit(:ticker, :industry, :inactive, :pse_security_id, :pse_company_id)
  end
end
