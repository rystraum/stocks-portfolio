# frozen_string_literal: true

class ChangeConvertedAnnouncementsToUuid < ActiveRecord::Migration[6.0]
  def up
    enable_extension "pgcrypto" unless extension_enabled?("pgcrypto")

    # Step 2: Create new table with UUID primary key, retaining all columns and old_id
    create_table :converted_announcements_new, id: :uuid do |t|
      t.bigint :old_id
      t.uuid :dividend_announcement_id
      t.uuid :user_id
      t.uuid :cash_dividend_id
      t.bigint :old_user_id
      t.bigint :old_cash_dividend_id
      t.datetime :created_at, precision: 6, null: false
      t.datetime :updated_at, precision: 6, null: false
    end

    # Step 3: Copy data from original table and assign new UUIDs
    execute <<-SQL
      INSERT INTO converted_announcements_new (
        id, old_id, dividend_announcement_id, user_id, cash_dividend_id, old_user_id, old_cash_dividend_id, created_at, updated_at
      )
      SELECT
        gen_random_uuid(), id, dividend_announcement_id, user_id, cash_dividend_id, old_user_id, old_cash_dividend_id, created_at, updated_at
      FROM converted_announcements;
    SQL
  end

  def down
    create_table :converted_announcements_old do |t|
      t.bigint :dividend_announcement_id
      t.bigint :user_id
      t.bigint :cash_dividend_id
      t.bigint :old_user_id
      t.bigint :old_cash_dividend_id
      t.datetime :created_at, precision: 6, null: false
      t.datetime :updated_at, precision: 6, null: false
    end
    add_index :converted_announcements_old, :dividend_announcement_id
    add_index :converted_announcements_old, :user_id
    add_index :converted_announcements_old, :cash_dividend_id
    add_index :converted_announcements_old, %i[dividend_announcement_id old_user_id], unique: true, name: "index_converted_dx_user_id"

    # Copy data (UUIDs will be lost)
    execute <<-SQL
      INSERT INTO converted_announcements_old (
        dividend_announcement_id, user_id, cash_dividend_id, old_user_id, old_cash_dividend_id, created_at, updated_at
      )
      SELECT
        dividend_announcement_id, user_id, cash_dividend_id, old_user_id, old_cash_dividend_id, created_at, updated_at
      FROM converted_announcements;
    SQL
  end
end
