class FinalizeConvertedAnnouncementsToUuid < ActiveRecord::Migration[6.0]
  def up
    # Step 4: Drop dependent foreign keys (if any exist)
    remove_foreign_key :converted_announcements, :dividend_announcements if foreign_key_exists?(:converted_announcements, :dividend_announcements)
    remove_foreign_key :converted_announcements, :users if foreign_key_exists?(:converted_announcements, :users)
    remove_foreign_key :converted_announcements, :cash_dividends if foreign_key_exists?(:converted_announcements, :cash_dividends)

    # Step 5: Swap tables
    drop_table :converted_announcements
    rename_table :converted_announcements_new, :converted_announcements

    # Step 6: Re-add foreign keys for uuid columns
    add_foreign_key :converted_announcements, :dividend_announcements, column: :dividend_announcement_id if !foreign_key_exists?(:converted_announcements, :dividend_announcements)
    add_foreign_key :converted_announcements, :users, column: :user_id if !foreign_key_exists?(:converted_announcements, :users)
    add_foreign_key :converted_announcements, :cash_dividends, column: :cash_dividend_id if !foreign_key_exists?(:converted_announcements, :cash_dividends)
  end

  def down
    rename_table :converted_announcements, :converted_announcements_new
    # Note: restoring the old table is not implemented here for safety
  end
end
