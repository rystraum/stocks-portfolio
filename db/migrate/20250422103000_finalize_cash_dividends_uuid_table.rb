class FinalizeCashDividendsUuidTable < ActiveRecord::Migration[6.0]
  def up
    # Step 11: Remove old table and finalize references
    remove_foreign_key :converted_announcements, column: :cash_dividend_id if foreign_key_exists?(:converted_announcements, :cash_dividends_new, column: :cash_dividend_id)
    drop_table :cash_dividends
    rename_table :cash_dividends_new, :cash_dividends
    add_foreign_key :converted_announcements, :cash_dividends, column: :cash_dividend_id
  end

  def down
    remove_foreign_key :converted_announcements, column: :cash_dividend_id if foreign_key_exists?(:converted_announcements, :cash_dividends, column: :cash_dividend_id)
    rename_table :cash_dividends, :cash_dividends_new
    # Note: restoring the old table is not implemented here for safety
  end
end
