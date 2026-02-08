# frozen_string_literal: true

class PopulatePriceUpdateUuidInReferencingTables < ActiveRecord::Migration[6.0]
  def up
    # Step 6: Create temporary columns to store the new UUID foreign keys
    add_column :cash_dividends, :last_price_update_uuid, :uuid
    add_column :stock_dividends, :last_price_update_uuid, :uuid

    # Step 7: Populate the temporary UUID columns by looking up price_updates by old_id
    execute <<-SQL
      UPDATE cash_dividends SET last_price_update_uuid = price_updates_new.id FROM price_updates_new WHERE cash_dividends.last_price_update_id = price_updates_new.old_id;
      UPDATE stock_dividends SET last_price_update_uuid = price_updates_new.id FROM price_updates_new WHERE stock_dividends.last_price_update_id = price_updates_new.old_id;
    SQL
  end

  def down
    remove_column :cash_dividends, :last_price_update_uuid
    remove_column :stock_dividends, :last_price_update_uuid
  end
end
