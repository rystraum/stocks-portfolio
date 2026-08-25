# frozen_string_literal: true

class AddCashDividendUuidToConvertedAnnouncements < ActiveRecord::Migration[6.0]
  def up
    # Step 6: Create temporary column for UUID reference
    add_column :converted_announcements, :cash_dividend_uuid, :uuid

    # Step 7: Update temporary column with UUID references using old_id
    execute <<-SQL
      UPDATE converted_announcements ca
      SET cash_dividend_uuid = (
        SELECT cd.id FROM cash_dividends_new cd WHERE cd.old_id = ca.cash_dividend_id
      )
      WHERE ca.cash_dividend_id IS NOT NULL;
    SQL
  end

  def down
    remove_column :converted_announcements, :cash_dividend_uuid
  end
end
