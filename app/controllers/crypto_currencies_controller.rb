class CryptoCurrenciesController < ApplicationController
  before_action :set_crypto_currency, only: [:show]

  # GET /crypto_currencies
  def index
    @crypto_currencies = CryptoCurrency.alphabetical
    @crypto_currency = CryptoCurrency.new
  end

  # GET /crypto_currencies/new
  def new
    @crypto_currency = CryptoCurrency.new
  end

  # POST /crypto_currencies
  def create
    @crypto_currency = CryptoCurrency.new(crypto_currency_params)
    if @crypto_currency.save
      redirect_to @crypto_currency, notice: 'Crypto currency was successfully created.'
    else
      render :new
    end
  end

  # GET /crypto_currencies/:id
  def show
  end

  private

  def set_crypto_currency
    @crypto_currency = CryptoCurrency.find_by(id: params[:id]) || CryptoCurrency.find_by(ticker: params[:id])
  end

  def crypto_currency_params
    params.require(:crypto_currency).permit(:name, :ticker, :last_price, :last_price_at, :decimal_places)
  end
end
