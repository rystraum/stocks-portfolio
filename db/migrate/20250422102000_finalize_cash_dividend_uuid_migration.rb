# frozen_string_literal: true

class FinalizeCashDividendUuidMigration < ActiveRecord::Migration[6.0]
  def up
    # Step 8: Rename old foreign key column
    rename_column :converted_announcements, :cash_dividend_id, :old_cash_dividend_id

    # Step 9: Rename temporary UUID column to original foreign key name
    rename_column :converted_announcements, :cash_dividend_uuid, :cash_dividend_id

    # Step 10: Re-add foreign key and indexes
    remove_index :converted_announcements, :old_cash_dividend_id if index_exists?(:converted_announcements, :old_cash_dividend_id)
    add_index :converted_announcements, :cash_dividend_id
    add_foreign_key :converted_announcements, :cash_dividends_new, column: :cash_dividend_id
  end

  def down
    # Reverse the column renames
    rename_column :converted_announcements, :cash_dividend_id, :cash_dividend_uuid
    rename_column :converted_announcements, :old_cash_dividend_id, :cash_dividend_id
    remove_index :converted_announcements, :cash_dividend_id if index_exists?(:converted_announcements, :cash_dividend_id)
    add_index :converted_announcements, :cash_dividend_id
    remove_foreign_key :converted_announcements, column: :cash_dividend_id if foreign_key_exists?(:converted_announcements, :cash_dividends_new,
                                                                                                  column: :cash_dividend_id,)
  end
end
