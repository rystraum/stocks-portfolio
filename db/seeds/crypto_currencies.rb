# Seed initial CryptoCurrency data
CryptoCurrency.upsert_all([
  {
    name: 'Bitcoin',
    ticker: 'BTC',
    last_price: 0,
    last_price_at: nil,
    decimal_places: 8,
    created_at: Time.current,
    updated_at: Time.current
  },
  {
    name: 'Ethereum',
    ticker: 'ETH',
    last_price: 0,
    last_price_at: nil,
    decimal_places: 8,
    created_at: Time.current,
    updated_at: Time.current
  },
  {
    name: 'Polkadot',
    ticker: 'POL',
    last_price: 0,
    last_price_at: nil,
    decimal_places: 8,
    created_at: Time.current,
    updated_at: Time.current
  }
], unique_by: :ticker)
