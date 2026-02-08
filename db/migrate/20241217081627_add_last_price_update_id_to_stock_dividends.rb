# frozen_string_literal: true

class AddLastPriceUpdateIdToStockDividends < ActiveRecord::Migration[6.1]
  def change
    add_reference :stock_dividends, :last_price_update, foreign_key: { to_table: :price_updates, column: :id }
  end
end
