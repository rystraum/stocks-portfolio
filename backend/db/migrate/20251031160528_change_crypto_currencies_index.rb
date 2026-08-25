# frozen_string_literal: true

class ChangeCryptoCurrenciesIndex < ActiveRecord::Migration[6.1]
  def change
    remove_index :crypto_currencies, :ticker
    add_index :crypto_currencies, %i[ticker quote_token], unique: true
  end
end
