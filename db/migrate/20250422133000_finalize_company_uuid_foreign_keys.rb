class FinalizeCompanyUuidForeignKeys < ActiveRecord::Migration[6.0]
  def up
    # drop old foreign keys first
    remove_foreign_key :activities, column: :company_id if foreign_key_exists?(:activities, column: :company_id)
    remove_foreign_key :cash_dividends, column: :company_id if foreign_key_exists?(:cash_dividends, column: :company_id)
    remove_foreign_key :dividend_announcements, column: :company_id if foreign_key_exists?(:dividend_announcements, column: :company_id)
    remove_foreign_key :price_updates, column: :company_id if foreign_key_exists?(:price_updates, column: :company_id)
    remove_foreign_key :stock_dividends, column: :company_id if foreign_key_exists?(:stock_dividends, column: :company_id)

    # Step 8: Rename old foreign key columns
    rename_column :activities, :company_id, :old_company_id
    rename_column :cash_dividends, :company_id, :old_company_id
    rename_column :dividend_announcements, :company_id, :old_company_id
    rename_column :price_updates, :company_id, :old_company_id
    rename_column :stock_dividends, :company_id, :old_company_id

    drop_table :companies
    rename_table :companies_new, :companies

    # Step 9: Rename temporary UUID columns to original foreign key names
    rename_column :activities, :company_uuid, :company_id
    rename_column :cash_dividends, :company_uuid, :company_id
    rename_column :dividend_announcements, :company_uuid, :company_id
    rename_column :price_updates, :company_uuid, :company_id
    rename_column :stock_dividends, :company_uuid, :company_id

    # Step 10: Re-add foreign keys for company_id (now UUID)
    add_foreign_key :activities, :companies, column: :company_id
    add_foreign_key :cash_dividends, :companies, column: :company_id
    add_foreign_key :dividend_announcements, :companies, column: :company_id
    add_foreign_key :price_updates, :companies, column: :company_id
    add_foreign_key :stock_dividends, :companies, column: :company_id
  end

  def down
    # drop new foreign keys first
    remove_foreign_key :activities, column: :company_uuid if foreign_key_exists?(:activities, column: :company_uuid)
    remove_foreign_key :cash_dividends, column: :company_uuid if foreign_key_exists?(:cash_dividends, column: :company_uuid)
    remove_foreign_key :dividend_announcements, column: :company_uuid if foreign_key_exists?(:dividend_announcements, column: :company_uuid)
    remove_foreign_key :price_updates, column: :company_uuid if foreign_key_exists?(:price_updates, column: :company_uuid)
    remove_foreign_key :stock_dividends, column: :company_uuid if foreign_key_exists?(:stock_dividends, column: :company_uuid)

    # Step 8: Rename old foreign key columns
    rename_column :activities, :old_company_id, :company_id
    rename_column :cash_dividends, :old_company_id, :company_id
    rename_column :dividend_announcements, :old_company_id, :company_id
    rename_column :price_updates, :old_company_id, :company_id
    rename_column :stock_dividends, :old_company_id, :company_id

    remove_foreign_key :activities, column: :company_id
    remove_foreign_key :cash_dividends, column: :company_id
    remove_foreign_key :dividend_announcements, column: :company_id
    remove_foreign_key :price_updates, column: :company_id
    remove_foreign_key :stock_dividends, column: :company_id
  end
end
