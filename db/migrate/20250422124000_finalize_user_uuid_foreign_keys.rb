class FinalizeUserUuidForeignKeys < ActiveRecord::Migration[6.0]
  def up
    # Step 9: Rename temporary UUID columns to original foreign key names
    rename_column :cash_dividends, :user_uuid, :user_id
    rename_column :stock_dividends, :user_uuid, :user_id
    rename_column :activities, :user_uuid, :user_id

    # Step 10: Re-add foreign keys for user_id (now UUID)
    add_foreign_key :cash_dividends, :users, column: :user_id
    add_foreign_key :stock_dividends, :users, column: :user_id
    add_foreign_key :activities, :users, column: :user_id

    # Step 10: Remove foreign keys referencing old_user_id, if any remain
    remove_foreign_key :cash_dividends, column: :old_user_id if foreign_key_exists?(:cash_dividends, column: :old_user_id)
    remove_foreign_key :stock_dividends, column: :old_user_id if foreign_key_exists?(:stock_dividends, column: :old_user_id)
    remove_foreign_key :activities, column: :old_user_id if foreign_key_exists?(:activities, column: :old_user_id)
  end

  def down
    # Reverse renames
    rename_column :cash_dividends, :user_id, :user_uuid
    rename_column :stock_dividends, :user_id, :user_uuid
    rename_column :activities, :user_id, :user_uuid
    rename_column :cash_dividends, :old_user_id, :user_id
    rename_column :stock_dividends, :old_user_id, :user_id
    rename_column :activities, :old_user_id, :user_id

    # Remove new foreign keys
    remove_foreign_key :cash_dividends, column: :user_uuid
    remove_foreign_key :stock_dividends, column: :user_uuid
    remove_foreign_key :activities, column: :user_uuid
  end
end
