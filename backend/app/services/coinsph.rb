# frozen_string_literal: true

class Coinsph
  def self.apikey
    Rails.application.credentials.coinsph_apikey
  end

  def self.secret_key
    Rails.application.credentials.coinsph_secretkey
  end

  def self.update_all!
    currencies = CryptoCurrency.coinsph
    tickers = currencies.collect(&:datasource_ticker)

    prices(tickers).parsed_response.each do |coin|
      crypto_currency = currencies.select { |c| c.datasource_ticker == coin["symbol"] }.first
      next if crypto_currency.nil?

      crypto_currency.update(last_price: coin["price"].to_d, last_price_at: Time.zone.now)
    end
  end

  def self.update!(crypto_currency)
    coin = prices([crypto_currency.datasource_ticker]).parsed_response.first
    return if coin.nil?

    crypto_currency.update(last_price: coin["price"].to_d, last_price_at: Time.zone.now)
  end

  def self.prices(tickers)
    HTTParty.get(
      "https://api.pro.coins.ph/openapi/quote/v1/ticker/price?symbols=[#{tickers.join(',')}]",
      headers: { "X-COINS-APIKEY" => apikey },
    )
  end

  def self.account
    get_with_signature("https://api.pro.coins.ph/openapi/v1/account", { timestamp: Time.now.to_i * 1_000 })
  end

  # Draft — not wired up to any scheduler yet.
  #
  # Buys ETH with a fixed PHP amount (default 2_000, matching the Thursday
  # auto-deposit) using a MARKET order on the ETHPHP pair. Uses quoteOrderQty
  # so the entire PHP amount is spent regardless of price.
  #
  # Verified against the official CoinsPH Postman collection (coins-api-postman):
  #   POST openapi/v1/order?symbol=..&side=buy&type=market&quoteOrderQty=..
  # Pass test: true to hit openapi/v1/order/test first (dry run, no execution).
  def self.place_market_order!(symbol: "ETHPHP", side: "BUY", quote_order_qty: 2_000, test: false)
    raise ArgumentError, "side must be BUY or SELL" unless %w[BUY SELL].include?(side)
    raise ArgumentError, "quote_order_qty must be positive" unless quote_order_qty.to_d > 0

    verify_trade_ready!(quote_order_qty) if side == "BUY"

    path = test ? "openapi/v1/order/test" : "openapi/v1/order"

    post_with_signature(
      "https://api.pro.coins.ph/#{path}",
      {
        symbol: symbol,
        side: side.downcase, # collection examples use lowercase: side=buy
        type: "market",
        quoteOrderQty: quote_order_qty,
        timestamp: Time.now.to_i * 1_000,
      }
    )
  end

  def self.verify_trade_ready!(php_amount)
    info = account.parsed_response

    php_balance = info.fetch("balances", [])
                      .select { |b| b["asset"] == "PHP" }
                      .first&.dig("free")&.to_d || 0

    raise "Insufficient PHP balance: #{php_balance} < #{php_amount}" if php_balance < php_amount.to_d
  end

  def self.post_with_signature(url, params)
    query_string = URI.encode_www_form(params)
    signature = OpenSSL::HMAC.hexdigest("SHA256", secret_key, query_string)

    options = {
      query: params.merge(signature: signature),
      headers: { "X-COINS-APIKEY" => apikey }
    }

    HTTParty.post(url, options)
  end

  # Draft — not wired up to any scheduler yet.
  #
  # Fills (executed trades) for a pair, e.g. Coinsph.my_trades(symbol: "ETHPHP").
  # Verified against the official Postman collection: GET openapi/v1/myTrades.
  # Response is Binance-compatible: id, orderId, price, qty, quoteQty,
  # commission, commissionAsset, time (ms epoch), isBuyerMaker.
  def self.my_trades(symbol:, limit: 100)
    get_with_signature(
      "https://api.pro.coins.ph/openapi/v1/myTrades",
      {
        symbol: symbol,
        limit: limit,
        timestamp: Time.now.to_i * 1_000,
      }
    )
  end

  # Draft — not wired up to any scheduler yet.
  #
  # Records CoinsPH fills as CryptoActivity rows (same target as the CSV
  # importer) so the weekly auto-buy shows up in cost basis / holdings.
  #
  # Mapping: qty -> crypto_amount, quoteQty -> fiat_amount (PHP),
  # commission -> fee_fiat when commissionAsset is PHP, fee_crypto otherwise.
  # Side: isBuyerMaker=false means we were the buyer. Dedupes via a
  # "coinsph:trade:<id>" marker in notes. Run after the market order fills,
  # e.g. Thursday 19:05.
  def self.record_my_trades!(user:, symbol: "ETHPHP")
    crypto_currency = CryptoCurrency.coinsph.find_by(datasource_ticker: symbol)
    raise "No coinsph CryptoCurrency for #{symbol}" if crypto_currency.nil?

    fills = my_trades(symbol: symbol).parsed_response

    fills.filter_map do |fill|
      marker = "coinsph:trade:#{fill['id']}"
      next if CryptoActivity.exists?(user: user, notes: marker)

      commission_asset = fill["commissionAsset"]

      CryptoActivity.create!(
        user: user,
        crypto_currency: crypto_currency,
        activity_type: fill["isBuyerMaker"] ? :sell : :buy,
        crypto_amount: fill["qty"],
        fiat_amount: fill["quoteQty"],
        fee_fiat: commission_asset == "PHP" ? fill["commission"] : 0,
        fee_crypto: commission_asset == "PHP" ? 0 : fill["commission"],
        fiat_currency: "PHP",
        activity_date: Time.zone.at(fill["time"] / 1_000).to_date,
        notes: marker,
      )
    end
  end

  def self.get_with_signature(url, params)
    query_string = URI.encode_www_form(params)
    signature = OpenSSL::HMAC.hexdigest("SHA256", secret_key, query_string)

    options = {
      query: params.merge(signature: signature),
      headers: { "X-COINS-APIKEY" => apikey }
    }

    HTTParty.get(url, options)
  end
end
