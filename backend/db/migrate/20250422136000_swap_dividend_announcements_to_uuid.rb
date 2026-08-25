# frozen_string_literal: true

class SwapDividendAnnouncementsToUuid < ActiveRecord::Migration[6.0]
  def up
    # Step 4: Drop dependent foreign keys
    remove_foreign_key :converted_announcements, column: :dividend_announcement_id if foreign_key_exists?(:converted_announcements,
                                                                                                          column: :dividend_announcement_id,)
    remove_foreign_key :dividend_announcements, :companies if foreign_key_exists?(:dividend_announcements, :companies)

    # Step 5: Swap tables
    drop_table :dividend_announcements
    rename_table :dividend_announcements_new, :dividend_announcements

    rename_column :converted_announcements, :dividend_announcement_id, :old_dividend_announcement_id
    rename_column :converted_announcements, :dividend_announcement_uuid, :dividend_announcement_id

    add_foreign_key :converted_announcements, :dividend_announcements, column: :dividend_announcement_id unless foreign_key_exists?(
      :converted_announcements, column: :dividend_announcement_id,
    )
    add_foreign_key :dividend_announcements, :companies, column: :company_id unless foreign_key_exists?(:dividend_announcements, :companies)
  end

  def down
    rename_table :dividend_announcements, :dividend_announcements_new
    # NOTE: restoring the old table is not implemented here for safety
  end
end
