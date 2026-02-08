# frozen_string_literal: true

class AddCompoundTickerToCryptoCurrencies < ActiveRecord::Migration[6.1]
  def change
    add_column :crypto_currencies, :compound_ticker, :string
    add_index :crypto_currencies, :compound_ticker
    reversible do |dir|
      dir.up do
        CryptoCurrency.all.find_each do |crypto_currency|
          crypto_currency.update_column(:compound_ticker, "#{crypto_currency.ticker}#{crypto_currency.quote_token}")
        end
      end
    end
  end
end
