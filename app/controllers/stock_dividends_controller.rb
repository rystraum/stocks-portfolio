class StockDividendsController < ApplicationController
  before_action :set_stock_dividend, only: [:show, :edit, :update, :destroy]

  # GET /stock_dividends
  # GET /stock_dividends.json
  def index
    @stock_dividends = StockDividend.all
  end

  # GET /stock_dividends/1
  # GET /stock_dividends/1.json
  def show
  end

  # GET /stock_dividends/new
  def new
    @stock_dividend = StockDividend.new
  end

  # GET /stock_dividends/1/edit
  def edit
  end

  # POST /stock_dividends
  # POST /stock_dividends.json
  def create
    @stock_dividend = StockDividend.new(stock_dividend_params)

    respond_to do |format|
      if @stock_dividend.save
        format.html { redirect_to @stock_dividend, notice: 'Stock dividend was successfully created.' }
        format.json { render :show, status: :created, location: @stock_dividend }
      else
        format.html { render :new }
        format.json { render json: @stock_dividend.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /stock_dividends/1
  # PATCH/PUT /stock_dividends/1.json
  def update
    respond_to do |format|
      if @stock_dividend.update(stock_dividend_params)
        format.html { redirect_to @stock_dividend, notice: 'Stock dividend was successfully updated.' }
        format.json { render :show, status: :ok, location: @stock_dividend }
      else
        format.html { render :edit }
        format.json { render json: @stock_dividend.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /stock_dividends/1
  # DELETE /stock_dividends/1.json
  def destroy
    @stock_dividend.destroy
    respond_to do |format|
      format.html { redirect_to stock_dividends_url, notice: 'Stock dividend was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_stock_dividend
      @stock_dividend = StockDividend.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def stock_dividend_params
      params.require(:stock_dividend).permit(:company_id, :amount, :pay_date, :ex_date)
    end
end
