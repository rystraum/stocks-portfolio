class PopulateUserUuidInReferencingTables < ActiveRecord::Migration[6.0]
  def up
    # Step 6: Create temporary columns to store the new UUID foreign keys
    add_column :cash_dividends, :user_uuid, :uuid
    add_column :stock_dividends, :user_uuid, :uuid
    add_column :activities, :user_uuid, :uuid

    # Step 7: Populate the temporary UUID columns by looking up users by old_id
    execute <<-SQL
      UPDATE cash_dividends SET user_uuid = users.id FROM users WHERE cash_dividends.old_user_id = users.old_id;
      UPDATE stock_dividends SET user_uuid = users.id FROM users WHERE stock_dividends.old_user_id = users.old_id;
      UPDATE activities SET user_uuid = users.id FROM users WHERE activities.old_user_id = users.old_id;
    SQL
  end

  def down
    remove_column :cash_dividends, :user_uuid
    remove_column :stock_dividends, :user_uuid
    remove_column :activities, :user_uuid
  end
end
