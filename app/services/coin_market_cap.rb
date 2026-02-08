# frozen_string_literal: true

class CoinMarketCap
  def self.apikey
    Rails.application.credentials.coinmarketcap_api_key
  end

  def self.update_all!
    currencies = CryptoCurrency.coinmarketcap

    tickers = currencies.collect(&:datasource_ticker)
    symbols, ids = tickers.partition { |t| Float(t, exception: false).nil? }
    convert_symbols = currencies.collect(&:fiat).uniq.compact

    if !symbols.empty?
      prices_by_symbol(symbols.uniq, convert_symbols).parsed_response["data"].each do |symbol, coins|
        coin = coins.first
        crypto_currency = currencies.select { |c| c.datasource_ticker == symbol && c.fiat == coin["quote"].keys.first }.first
        next if crypto_currency.nil?

        crypto_currency.update(datasource_ticker: coin["id"])
        ids << coin["id"]
      end
    end

    convert_symbols.each do |convert_symbol|
      response = prices_by_id(ids, [convert_symbol]).parsed_response["data"]
      ids.each do |id|
        coin_data = response[id]
        next if coin_data.blank?

        crypto_currency = currencies.select { |c| c.datasource_ticker == id.to_s && c.fiat == coin_data["quote"].keys.first }.first
        next if crypto_currency.nil?

        crypto_currency.update(
          last_price: coin_data["quote"][crypto_currency.fiat]["price"].to_d,
          last_price_at: Time.zone.now,
        )
      end
    end
  end

  def self.prices_by_id(ids, convert_symbols)
    HTTParty.get(
      "https://pro-api.coinmarketcap.com/v2/cryptocurrency/quotes/latest",
      query: {
        id: ids.join(","),
        convert: convert_symbols.join(",")
      },
      headers: { "X-CMC_PRO_API_KEY" => apikey },
    )
  end

  def self.prices_by_symbol(symbols, convert_symbols)
    HTTParty.get(
      "https://pro-api.coinmarketcap.com/v2/cryptocurrency/quotes/latest",
      query: {
        symbol: symbols.join(","),
        convert: convert_symbols.join(",")
      },
      headers: { "X-CMC_PRO_API_KEY" => apikey },
    )
  end
end
