# frozen_string_literal: true

class ChangeDividendAnnouncementsToUuid < ActiveRecord::Migration[6.0]
  def up
    enable_extension "pgcrypto" unless extension_enabled?("pgcrypto")

    # Step 2: Create new table with UUID primary key, retaining all columns and old_id
    create_table :dividend_announcements_new, id: :uuid do |t|
      t.bigint :old_id
      t.uuid :company_id, null: false
      t.string :share_class
      t.string :dividend_type
      t.decimal :amount
      t.date :ex_date
      t.date :record_date
      t.date :payout_date
      t.string :circular_number
      t.string :raw_html
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end
    add_index :dividend_announcements_new, :company_id
    add_index :dividend_announcements_new, :circular_number, unique: true

    # Step 3: Copy data from original table and assign new UUIDs
    execute <<-SQL
      INSERT INTO dividend_announcements_new (
        id, old_id, company_id, share_class, dividend_type, amount, ex_date, record_date, payout_date, circular_number, raw_html, created_at, updated_at
      )
      SELECT
        gen_random_uuid(), id, company_id, share_class, dividend_type, amount, ex_date, record_date, payout_date, circular_number, raw_html, created_at, updated_at
      FROM dividend_announcements;
    SQL
  end

  def down
    create_table :dividend_announcements_old do |t|
      t.bigint :company_id, null: false
      t.string :share_class
      t.string :dividend_type
      t.decimal :amount
      t.date :ex_date
      t.date :record_date
      t.date :payout_date
      t.string :circular_number
      t.string :raw_html
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end
    add_index :dividend_announcements_old, :company_id
    add_index :dividend_announcements_old, :circular_number, unique: true

    # Copy data (UUIDs will be lost)
    execute <<-SQL
      INSERT INTO dividend_announcements_old (
        company_id, share_class, dividend_type, amount, ex_date, record_date, payout_date, circular_number, raw_html, created_at, updated_at
      )
      SELECT
        company_id, share_class, dividend_type, amount, ex_date, record_date, payout_date, circular_number, raw_html, created_at, updated_at
      FROM dividend_announcements;
    SQL
  end
end
