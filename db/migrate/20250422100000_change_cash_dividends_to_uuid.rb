class ChangeCashDividendsToUuid < ActiveRecord::Migration[6.0]
  def up
    enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')

    # Step 1: Create new table with UUID primary key, retain old_id
    create_table :cash_dividends_new, id: :uuid do |t|
      t.bigint :old_id
      t.bigint :company_id
      t.decimal :amount, precision: 15, scale: 2
      t.date :pay_date
      t.date :ex_date
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.text :meta
      t.bigint :user_id
      t.bigint :last_price_update_id
    end
    add_index :cash_dividends_new, :company_id
    add_index :cash_dividends_new, :user_id
    add_index :cash_dividends_new, :last_price_update_id

    # Step 2: Copy data from original table and assign new UUIDs
    execute <<-SQL
      INSERT INTO cash_dividends_new (id, old_id, company_id, amount, pay_date, ex_date, created_at, updated_at, meta, user_id, last_price_update_id)
      SELECT gen_random_uuid(), id, company_id, amount, pay_date, ex_date, created_at, updated_at, meta, user_id, last_price_update_id FROM cash_dividends;
    SQL
  end

  def down
    create_table :cash_dividends_old do |t|
      t.decimal :amount, precision: 15, scale: 2
      t.date :pay_date
      t.date :ex_date
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.text :meta
      t.bigint :company_id
      t.bigint :user_id
      t.bigint :last_price_update_id
    end
    add_index :cash_dividends_old, :company_id
    add_index :cash_dividends_old, :user_id
    add_index :cash_dividends_old, :last_price_update_id

    # Copy data (UUIDs will be lost)
    execute <<-SQL
      INSERT INTO cash_dividends_old (amount, pay_date, ex_date, created_at, updated_at, meta, company_id, user_id, last_price_update_id)
      SELECT amount, pay_date, ex_date, created_at, updated_at, meta, company_id, user_id, last_price_update_id FROM cash_dividends;
    SQL
  end
end
