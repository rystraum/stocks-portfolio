class ChangeCompaniesToUuid < ActiveRecord::Migration[6.0]
  def up
    enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')

    # Step 2: Create new table with UUID primary key, retaining all columns and old_id
    create_table :companies_new, id: :uuid do |t|
      t.bigint :old_id
      t.string :ticker
      t.string :industry
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.boolean :inactive, default: false
      t.string :pse_security_id
      t.string :pse_company_id
      t.string :name
      t.decimal :target_buy_price, precision: 15, scale: 2
      t.string :target_price_note
      t.integer :dividend_frequency_months
    end
    add_index :companies_new, :industry
    add_index :companies_new, :ticker, unique: true

    # Step 3: Copy data from original table and assign new UUIDs
    execute <<-SQL
      INSERT INTO companies_new (id, old_id, ticker, industry, created_at, updated_at, inactive, pse_security_id, pse_company_id, name, target_buy_price, target_price_note, dividend_frequency_months)
      SELECT gen_random_uuid(), id, ticker, industry, created_at, updated_at, inactive, pse_security_id, pse_company_id, name, target_buy_price, target_price_note, dividend_frequency_months FROM companies;
    SQL
  end

  def down
    create_table :companies_old do |t|
      t.string :ticker
      t.string :industry
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.boolean :inactive, default: false
      t.string :pse_security_id
      t.string :pse_company_id
      t.string :name
      t.decimal :target_buy_price, precision: 15, scale: 2
      t.string :target_price_note
      t.integer :dividend_frequency_months
    end
    add_index :companies_old, :industry
    add_index :companies_old, :ticker, unique: true

    # Copy data (UUIDs will be lost)
    execute <<-SQL
      INSERT INTO companies_old (ticker, industry, created_at, updated_at, inactive, pse_security_id, pse_company_id, name, target_buy_price, target_price_note, dividend_frequency_months)
      SELECT ticker, industry, created_at, updated_at, inactive, pse_security_id, pse_company_id, name, target_buy_price, target_price_note, dividend_frequency_months FROM companies;
    SQL
  end
end
