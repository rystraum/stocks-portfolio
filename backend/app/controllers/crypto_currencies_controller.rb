# frozen_string_literal: true

class CryptoCurrenciesController < AuthenticatedUserController
  before_action :set_crypto_currency, only: %i[show edit update refresh_price pull_activities import_activities]

  # GET /crypto_currencies
  def index
    @crypto_currencies = CryptoCurrency.alphabetical
    @crypto_currency = CryptoCurrency.new(datasource: "https://api.pro.coins.ph/")
    @cost_bases = {}
    @crypto_currencies.each do |crypto|
      @cost_bases[crypto.id] = CryptoActivity.cost_basis(current_user.id, crypto.id)
    end
  end

  # GET /crypto_currencies/new
  def new
    return redirect_to(root_path, status: :forbidden) unless @permissions.can?(:create, CryptoCurrency)

    @crypto_currency = CryptoCurrency.new(datasource: "https://api.pro.coins.ph/")
  end

  # POST /crypto_currencies
  def create
    return redirect_to(root_path, status: :forbidden) unless @permissions.can?(:create, CryptoCurrency)

    @crypto_currency = CryptoCurrency.new(crypto_currency_params)
    if @crypto_currency.save
      redirect_to @crypto_currency, notice: "Crypto currency was successfully created."
    else
      render :new
    end
  end

  # GET /crypto_currencies/:id
  def show
    @activities = CryptoActivity.where(crypto_currency_id: @crypto_currency.id, user_id: current_user.id).order(activity_date: :desc,
                                                                                                                created_at: :desc,)
    @cost_basis = CryptoActivity.cost_basis(current_user.id, @crypto_currency.id)
    @net_crypto = CryptoActivity.net_crypto_amount(current_user.id, @crypto_currency.id)
    @total_fiat = CryptoActivity.total_fiat_spent(current_user.id, @crypto_currency.id)
    @total_proceeds = CryptoActivity.where(crypto_currency_id: @crypto_currency.id, user_id: current_user.id,
                                           activity_type: :sell,).sum("fiat_amount - COALESCE(fee_fiat, 0)")
    @current_value = @crypto_currency.last_price.blank? ? 0 : @net_crypto * @crypto_currency.last_price
    @current_value = 0 if @current_value.negative?
    @pnl = @current_value + @total_proceeds - @total_fiat
  end

  # POST /crypto_currencies/:id/refresh_price
  def refresh_price
    return redirect_back(fallback_location: @crypto_currency, alert: "No permissions") unless @permissions.can?(:update, @crypto_currency)

    if @crypto_currency.coinsph?
      Coinsph.update!(@crypto_currency)
    elsif @crypto_currency.coinmarketcap?
      CoinMarketCap.update!(@crypto_currency)
    else
      return redirect_back(fallback_location: @crypto_currency, alert: "No datasource configured.")
    end

    redirect_back(fallback_location: @crypto_currency, notice: "Price refreshed from #{@crypto_currency.datasource}.")
  end

  # POST /crypto_currencies/:id/pull_activities
  #
  # Fetches recent CoinsPH fills for this pair and renders a preview:
  # each trade is flagged as already-recorded (upstream reference exists),
  # a close candidate (looks like an existing manual/CSV activity), or new.
  def pull_activities
    return redirect_back(fallback_location: @crypto_currency, alert: "Pull is only supported for CoinsPH pairs.") unless @crypto_currency.coinsph?

    trades = fetch_trades
    return if trades.nil? # error already handled

    @trades = trades.map { |fill| Coinsph.normalize_trade(fill) }
    @trades.each do |trade|
      trade[:already_recorded] = Coinsph.already_recorded?(trade[:upstream_trade_id])
      trade[:close_candidate] = unless trade[:already_recorded]
        CryptoActivity.close_candidate_for(
          user_id: current_user.id,
          crypto_currency_id: @crypto_currency.id,
          **trade.slice(:activity_type, :crypto_amount, :fiat_amount, :activity_date)
        )
      end
    end
    @trades.sort_by! { |t| t[:activity_date] }.reverse!
  end

  # POST /crypto_currencies/:id/import_activities
  #
  # Creates CryptoActivity rows for the trade ids selected in the pull
  # preview. Amounts are re-read from the API rather than trusted from the
  # form; upstream_trade_id keeps later pulls from offering the same trade.
  def import_activities
    return redirect_back(fallback_location: @crypto_currency, alert: "Pull is only supported for CoinsPH pairs.") unless @crypto_currency.coinsph?

    wanted_ids = params[:trade_ids].to_a.map(&:to_s)
    return redirect_to(@crypto_currency, alert: "No activities selected.") if wanted_ids.empty?

    fills = fetch_trades
    return if fills.nil? # error already handled

    created = 0
    skipped = 0

    fills.each do |fill|
      next unless wanted_ids.include?(fill["id"].to_s)

      attrs = Coinsph.normalize_trade(fill)
      if Coinsph.already_recorded?(attrs[:upstream_trade_id])
        skipped += 1
        next
      end

      CryptoActivity.create!(attrs.merge(user: current_user, crypto_currency: @crypto_currency))
      created += 1
    end

    message = "Imported #{created} #{'activity'.pluralize(created)}."
    message += " Skipped #{skipped} already recorded." if skipped.positive?
    redirect_to @crypto_currency, notice: message
  end

  # GET /crypto_currencies/:id/edit
  def edit
    # Uses @crypto_currency from before_action

    return redirect_to(root_path, status: :forbidden) unless @permissions.can?(:update, @crypto_currency)
  end

  # PATCH/PUT /crypto_currencies/:id
  def update
    return redirect_to(root_path, status: :forbidden) unless @permissions.can?(:update, @crypto_currency)

    last_price_before = @crypto_currency.last_price
    if @crypto_currency.update(crypto_currency_params)
      if crypto_currency_params[:last_price] && crypto_currency_params[:last_price] != last_price_before.to_s
        @crypto_currency.update(last_price_at: Time.current)
      end
      redirect_to @crypto_currency, notice: "Crypto currency was successfully updated."
    else
      render :edit
    end
  end

  private

  # Returns an Array of fill hashes, or nil after redirecting with an alert.
  # CoinsPH returns HTTP 200 with {"code":..., "msg":...} for API errors
  # (e.g. IP whitelist), so the body shape must be checked, not just status.
  def fetch_trades
    response = Coinsph.my_trades(symbol: @crypto_currency.datasource_ticker, limit: 50)

    parsed = response.parsed_response
    if response.code == 200 && parsed.is_a?(Array)
      return parsed
    end

    detail = if parsed.is_a?(Hash)
               link = " <a href=\"https://www.coins.ph/en-ph/usercenter/settings/api-management\" class=\"underline\">Manage your CoinsPH API keys</a>" if parsed["code"] == -2017
               "#{parsed['msg']} (code #{parsed['code']})#{link}"
             else
               "HTTP #{response.code}: #{response.body}"
             end
    redirect_back(fallback_location: @crypto_currency, alert: "CoinsPH request failed: #{detail}")
    nil
  end

  def set_crypto_currency
    @crypto_currency = CryptoCurrency.find_by(id: params[:id]) || CryptoCurrency.find_by(compound_ticker: params[:id])
  end

  def crypto_currency_params
    params.require(:crypto_currency).permit(:name, :ticker, :last_price, :datasource, :datasource_ticker, :quote_token)
  end
end
