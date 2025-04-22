class SwapStockDividendsToUuid < ActiveRecord::Migration[6.0]
  def up
    # Step 4: Drop dependent foreign keys (none found for stock_dividends)
    # Step 5: Rename new table to old table name
    drop_table :stock_dividends
    rename_table :stock_dividends_new, :stock_dividends
    # Step 10: Re-add foreign keys (if any were dropped, none in this case)
  end

  def down
    rename_table :stock_dividends, :stock_dividends_new
    # Note: restoring the old table is not implemented here for safety
  end
end
