class Coinsph
  def self.update_all!
    tickers = CryptoCurrency.pluck(:ticker).collect { |ticker| "#{ticker.upcase}PHP" }
    apikey = Rails.application.credentials.coinsph_apikey
    response = HTTParty.get(
      "https://api.pro.coins.ph/openapi/quote/v1/ticker/price?symbols=[#{tickers.join(",")}]", 
      headers: { "X-COINS-APIKEY" => apikey }
    )
    # Response looks like this:
    #   [
    #     {
    #         "symbol": "BTCPHP",
    #         "price": "5382856.9"
    #     },
    #     {
    #         "symbol": "ETHPHP",
    #         "price": "101906.4"
    #     },
    #     {
    #         "symbol": "SUIPHP",
    #         "price": "189"
    #     }
    # ]
    
    response.parsed_response.each do |coin|
      crypto_currency = CryptoCurrency.find_by(ticker: coin["symbol"].gsub("PHP", ""))
      next if crypto_currency.nil?
      crypto_currency.update(last_price: coin["price"].to_d, last_price_at: Time.now)
    end
  end
end