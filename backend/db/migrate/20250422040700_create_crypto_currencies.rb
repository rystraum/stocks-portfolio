# frozen_string_literal: true

class CreateCryptoCurrencies < ActiveRecord::Migration[6.0]
  def change
    create_table :crypto_currencies do |t|
      t.string :name, null: false
      t.string :ticker, null: false
      t.integer :last_price
      t.datetime :last_price_at
      t.integer :decimal_places, null: false, default: 8
      t.timestamps
    end
    add_index :crypto_currencies, :ticker, unique: true
  end
end
