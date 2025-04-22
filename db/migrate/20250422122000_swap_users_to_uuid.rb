class SwapUsersToUuid < ActiveRecord::Migration[6.0]
  def up
    # Step 4: Drop dependent foreign keys
    remove_foreign_key :cash_dividends, :users if foreign_key_exists?(:cash_dividends, :users)
    remove_foreign_key :stock_dividends, :users if foreign_key_exists?(:stock_dividends, :users)
    remove_foreign_key :activities, :users if foreign_key_exists?(:activities, :users)

    # Step 5: Rename new table to old table name
    drop_table :users
    rename_table :users_new, :users
    # Step 10: Re-add foreign keys (to be handled in referencing tables)
  end

  def down
    rename_table :users, :users_new
    # Note: restoring the old table is not implemented here for safety
  end
end
