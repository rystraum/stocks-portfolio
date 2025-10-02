# frozen_string_literal: true

class CompaniesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_company, only: %i[show edit update destroy last_price price_update_from_pse refetch_announcements]

  # GET /companies
  # GET /companies.json
  def index
    @companies = Company.alphabetical
    @company = Company.new
  end

  # GET /companies/1
  # GET /companies/1.json
  def show
    if @company.nil?
      redirect_to companies_path, alert: "Company not found."
    elsif @company.id.to_s == params[:id]
      redirect_to company_path(@company.ticker), status: :moved_permanently
    end

    current_user.company_dividends(@company).each do |dividend|
      next if !dividend.is_a?(CashDividend)
      next if !dividend.dividend_per_share.blank?

      puts "Setting meta for #{dividend.id}"

      dividend.set_meta!(true)
    end
  end

  def price_update_all_from_pse
    if !@permissions.can?(:price_update, Company)
      return redirect_back(fallback_location: companies_url, alert: "No permissions")
    end

    count = PriceUpdateCompanies.new.run!
    respond_to do |format|
      format.html do
        flash[:notice] = "Queued price update for #{count} companies."
        redirect_back(fallback_location: companies_url)
      end
    end
  end

  def price_update_from_pse
    if !@permissions.can?(:price_update, @company)
      return redirect_back(fallback_location: @company, alert: "No permissions")
    end
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
    if !@permissions.can?(:create, Company)
      return redirect_back(fallback_location: companies_url, alert: "No permissions")
    end
    @company = Company.new
  end

  # GET /companies/1/edit
  def edit
    if !@permissions.can?(:update, @company)
      return redirect_back(fallback_location: @company, alert: "No permissions")
    end
  end

  # POST /companies
  # POST /companies.json
  def create
    if !@permissions.can?(:create, Company)
      return redirect_back(fallback_location: companies_url, alert: "No permissions")
    end

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
    if !@permissions.can?(:update, @company)
      return redirect_back(fallback_location: @company, alert: "No permissions")
    end

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
    if !@permissions.can?(:delete, @company)
      return redirect_back(fallback_location: @company, alert: "No permissions")
    end

    @company.destroy
    respond_to do |format|
      format.html { redirect_to companies_url, notice: 'Company was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def refetch_announcements
    # @company.dividend_announcements.delete_all

    pse = PSE.new(@company)
    pse.dividend_announcements!

    return redirect_back(fallback_location: @company, notice: "Dividend Announcements Refetched!")
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_company
    @company = Company.find_by(id: params[:id]) || Company.find_by(ticker: params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def company_params
    params.require(:company).permit(
      :ticker,
      :industry,
      :inactive,
      :pse_security_id,
      :pse_company_id,
      :name,
      :target_buy_price,
      :target_price_note,
      :dividend_frequency_months,
    )
  end
end
