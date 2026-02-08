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

  def self.prices(tickers)
    HTTParty.get(
      "https://api.pro.coins.ph/openapi/quote/v1/ticker/price?symbols=[#{tickers.join(',')}]",
      headers: { "X-COINS-APIKEY" => apikey },
    )
  end

  def self.account
    get_with_signature("https://api.pro.coins.ph/openapi/v1/account", { timestamp: Time.now.to_i * 1_000 })
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
