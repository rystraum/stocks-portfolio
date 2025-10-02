class CryptoPriceUpdate
  def self.update_all!
    CoinMarketCap.update_all!
    Coinsph.update_all!
  end
end