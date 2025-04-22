class SwapPriceUpdatesToUuid < ActiveRecord::Migration[6.0]
  def up
    # Step 4: Drop dependent foreign keys
    remove_foreign_key :cash_dividends, column: :last_price_update_id if foreign_key_exists?(:cash_dividends, column: :last_price_update_id)
    remove_foreign_key :stock_dividends, column: :last_price_update_id if foreign_key_exists?(:stock_dividends, column: :last_price_update_id)

    # Step 5: Swap tables
    drop_table :price_updates
    rename_table :price_updates_new, :price_updates
  end

  def down
    rename_table :price_updates, :price_updates_new
    # Note: restoring the old table is not implemented here for safety
  end
end
