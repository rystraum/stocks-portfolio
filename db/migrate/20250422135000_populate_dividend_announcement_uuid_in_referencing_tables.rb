# frozen_string_literal: true

class PopulateDividendAnnouncementUuidInReferencingTables < ActiveRecord::Migration[6.0]
  def up
    # Step 6: Create temporary columns to store the new UUID foreign keys
    add_column :converted_announcements, :dividend_announcement_uuid, :uuid

    # Step 7: Populate the temporary UUID columns by looking up dividend_announcements_new by old_id
    execute <<-SQL
      UPDATE converted_announcements SET dividend_announcement_uuid = dividend_announcements_new.id FROM dividend_announcements_new WHERE converted_announcements.dividend_announcement_id = dividend_announcements_new.old_id;
    SQL
  end

  def down
    remove_column :converted_announcements, :dividend_announcement_uuid
  end
end
