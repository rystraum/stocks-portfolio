# frozen_string_literal: true

class ReaddCashDividendsForeignKeys < ActiveRecord::Migration[6.0]
  def up
    add_foreign_key :cash_dividends, :companies
    add_foreign_key :cash_dividends, :price_updates, column: :last_price_update_id
    add_foreign_key :cash_dividends, :users
  end

  def down
    remove_foreign_key :cash_dividends, :companies
    remove_foreign_key :cash_dividends, :price_updates, column: :last_price_update_id
    remove_foreign_key :cash_dividends, :users
  end
end
