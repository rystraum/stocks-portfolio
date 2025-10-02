class CryptoCurrenciesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_crypto_currency, only: [:show, :edit, :update]

  # GET /crypto_currencies
  def index
    @crypto_currencies = CryptoCurrency.alphabetical
    @crypto_currency = CryptoCurrency.new(datasource: 'https://api.pro.coins.ph/')
    @cost_bases = {}
    @crypto_currencies.each do |crypto|
      @cost_bases[crypto.id] = CryptoActivity.cost_basis(current_user.id, crypto.id)
    end
  end

  # GET /crypto_currencies/new
  def new
    return redirect_to(root_path, status: :forbidden) if !@permissions.can?(:create, CryptoCurrency)
    @crypto_currency = CryptoCurrency.new(datasource: 'https://api.pro.coins.ph/')
  end

  # POST /crypto_currencies
  def create
    return redirect_to(root_path, status: :forbidden) if !@permissions.can?(:create, CryptoCurrency)
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
    @current_value = @crypto_currency.last_price.blank? ? 0 : @net_crypto * @crypto_currency.last_price
    @current_value = 0 if @current_value.negative?
    @pnl = @current_value + @total_proceeds - @total_fiat
  end

  # GET /crypto_currencies/:id/edit
  def edit
    # Uses @crypto_currency from before_action

    return redirect_to(root_path, status: :forbidden) if !@permissions.can?(:update, @crypto_currency)
  end

  # PATCH/PUT /crypto_currencies/:id
  def update
    return redirect_to(root_path, status: :forbidden) if !@permissions.can?(:update, @crypto_currency)

    last_price_before = @crypto_currency.last_price
    if @crypto_currency.update(crypto_currency_params)
      if crypto_currency_params[:last_price] && crypto_currency_params[:last_price] != last_price_before.to_s
        @crypto_currency.update_column(:last_price_at, Time.current)
      end
      redirect_to @crypto_currency, notice: 'Crypto currency was successfully updated.'
    else
      render :edit
    end
  end

  private

  def set_crypto_currency
    @crypto_currency = CryptoCurrency.find_by(id: params[:id]) || CryptoCurrency.find_by(ticker: params[:id])
  end

  def crypto_currency_params
    params.require(:crypto_currency).permit(:name, :ticker, :last_price, :datasource, :datasource_ticker)
  end
end
