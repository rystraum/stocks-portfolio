class CryptoCurrenciesController < ApplicationController
  before_action :set_crypto_currency, only: [:show]

  # GET /crypto_currencies
  def index
    @crypto_currencies = CryptoCurrency.alphabetical
    @crypto_currency = CryptoCurrency.new
    @cost_bases = {}
    @crypto_currencies.each do |crypto|
      @cost_bases[crypto.id] = CryptoActivity.cost_basis(current_user.id, crypto.id)
    end
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
    @activities = CryptoActivity.where(crypto_currency_id: @crypto_currency.id, user_id: current_user.id).order(activity_date: :desc, created_at: :desc)
    @cost_basis = CryptoActivity.cost_basis(current_user.id, @crypto_currency.id)
    @net_crypto = CryptoActivity.net_crypto_amount(current_user.id, @crypto_currency.id)
    @total_fiat = CryptoActivity.total_fiat_spent(current_user.id, @crypto_currency.id)
    @total_proceeds = CryptoActivity.where(crypto_currency_id: @crypto_currency.id, user_id: current_user.id, activity_type: :sell).sum('fiat_amount - COALESCE(fee_fiat, 0)')
    @pnl = @total_proceeds - (@cost_basis * (@net_crypto < 0 ? -@net_crypto : 0))
  end

  private

  def set_crypto_currency
    @crypto_currency = CryptoCurrency.find_by(id: params[:id]) || CryptoCurrency.find_by(ticker: params[:id])
  end

  def crypto_currency_params
    params.require(:crypto_currency).permit(:name, :ticker, :last_price, :last_price_at, :decimal_places)
  end
end
