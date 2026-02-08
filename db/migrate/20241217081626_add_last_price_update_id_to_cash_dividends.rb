# frozen_string_literal: true

class AddLastPriceUpdateIdToCashDividends < ActiveRecord::Migration[6.1]
  def change
    add_reference :cash_dividends, :last_price_update, foreign_key: { to_table: :price_updates, column: :id }
  end
end
