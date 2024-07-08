class CashDividendsController < ApplicationController
  before_action :set_cash_dividend, only: %i[show edit update destroy update_meta]
  before_action :authenticate_user!

  # GET /cash_dividends
  # GET /cash_dividends.json
  def index
    @costs_calculator = CostsCalculator.new(current_user.activities)
    @cash_dividends = CashDividendSet.new(current_user.cash_dividends.order('pay_date desc'))
    @stock_dividends = current_user.stock_dividends.order('pay_date desc')
    @companies = CompanySet.new(
      UserPortfolio.new(current_user).companies,
      current_user
    ).companies
  end

  # GET /cash_dividends/1
  # GET /cash_dividends/1.json
  def show; end

  # GET /cash_dividends/new
  def new
    @cash_dividend = CashDividend.new
  end

  # GET /cash_dividends/1/edit
  def edit; end

  # POST /cash_dividends
  # POST /cash_dividends.json
  def create
    @cash_dividend = current_user.cash_dividends.build(cash_dividend_params)

    respond_to do |format|
      if @cash_dividend.save
        format.html { redirect_to @cash_dividend, notice: 'Cash dividend was successfully created.' }
        format.json { render :show, status: :created, location: @cash_dividend }
      else
        format.html { render :new }
        format.json { render json: @cash_dividend.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /cash_dividends/1
  # PATCH/PUT /cash_dividends/1.json
  def update
    respond_to do |format|
      if @cash_dividend.update(cash_dividend_params)
        format.html { redirect_back(fallback_location: @cash_dividend, notice: 'Cash dividend was successfully updated.') }
        format.json { render :show, status: :ok, location: @cash_dividend }
      else
        format.html { render :edit }
        format.json { render json: @cash_dividend.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cash_dividends/1
  # DELETE /cash_dividends/1.json
  def destroy
    @cash_dividend.destroy
    respond_to do |format|
      format.html { redirect_to cash_dividends_url, notice: 'Cash dividend was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def update_meta
    @cash_dividend.set_meta(true)
    respond_to do |format|
      if @cash_dividend.save
        format.html { redirect_back(fallback_location: @cash_dividend, notice: 'Cash dividend was successfully updated.') }
        format.json { render :show, status: :ok, location: @cash_dividend }
      else
        format.html { render :edit }
        format.json { render json: @cash_dividend.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_cash_dividend
    @cash_dividend = current_user.cash_dividends.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def cash_dividend_params
    params.require(:cash_dividend).permit(:company_id, :amount, :pay_date, :ex_date)
  end
end
