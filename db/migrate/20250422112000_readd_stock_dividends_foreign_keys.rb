# frozen_string_literal: true

class ReaddStockDividendsForeignKeys < ActiveRecord::Migration[6.0]
  def up
    add_foreign_key :stock_dividends, :companies
    add_foreign_key :stock_dividends, :price_updates, column: :last_price_update_id
    add_foreign_key :stock_dividends, :users
  end

  def down
    remove_foreign_key :stock_dividends, :companies
    remove_foreign_key :stock_dividends, :price_updates, column: :last_price_update_id
    remove_foreign_key :stock_dividends, :users
  end
end
