class FinalizePriceUpdateUuidForeignKeys < ActiveRecord::Migration[6.0]
  def up
    # Step 8: Rename old foreign key columns
    rename_column :cash_dividends, :last_price_update_id, :old_last_price_update_id
    rename_column :stock_dividends, :last_price_update_id, :old_last_price_update_id

    # Step 9: Rename temporary UUID columns to original foreign key names
    rename_column :cash_dividends, :last_price_update_uuid, :last_price_update_id
    rename_column :stock_dividends, :last_price_update_uuid, :last_price_update_id

    # Step 10: Re-add foreign keys for last_price_update_id (now UUID)
    add_foreign_key :cash_dividends, :price_updates, column: :last_price_update_id
    add_foreign_key :stock_dividends, :price_updates, column: :last_price_update_id
  end

  def down
    rename_column :cash_dividends, :last_price_update_id, :last_price_update_uuid
    rename_column :stock_dividends, :last_price_update_id, :last_price_update_uuid
    rename_column :cash_dividends, :old_last_price_update_id, :last_price_update_id
    rename_column :stock_dividends, :old_last_price_update_id, :last_price_update_id

    remove_foreign_key :cash_dividends, column: :last_price_update_id
    remove_foreign_key :stock_dividends, column: :last_price_update_id
  end
end
