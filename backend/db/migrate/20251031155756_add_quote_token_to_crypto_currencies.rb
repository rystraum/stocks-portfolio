# frozen_string_literal: true

class AddQuoteTokenToCryptoCurrencies < ActiveRecord::Migration[6.1]
  def change
    add_column :crypto_currencies, :quote_token, :string

    reversible do |dir|
      dir.up do
        CryptoCurrency.all.find_each do |crypto_currency|
          crypto_currency.update_column(:quote_token, crypto_currency.fiat)
        end
      end
    end
  end
end
