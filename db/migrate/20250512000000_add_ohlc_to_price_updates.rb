# frozen_string_literal: true

class AddOhlcToPriceUpdates < ActiveRecord::Migration[7.2]
  def change
    add_column :price_updates, :open, :decimal, precision: 15, scale: 2
    add_column :price_updates, :high, :decimal, precision: 15, scale: 2
    add_column :price_updates, :low, :decimal, precision: 15, scale: 2
  end
end
