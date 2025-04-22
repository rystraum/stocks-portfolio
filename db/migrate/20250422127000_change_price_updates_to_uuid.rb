class ChangePriceUpdatesToUuid < ActiveRecord::Migration[6.0]
  def up
    enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')

    # Step 2: Create new table with UUID primary key, retaining all columns and old_id
    create_table :price_updates_new, id: :uuid do |t|
      t.bigint :old_id
      t.bigint :company_id # companies is still bigint
      t.datetime :datetime
      t.decimal :price, precision: 15, scale: 2
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.text :notes
    end
    add_index :price_updates_new, :company_id

    # Step 3: Copy data from original table and assign new UUIDs
    execute <<-SQL
      INSERT INTO price_updates_new (id, old_id, company_id, datetime, price, created_at, updated_at, notes)
      SELECT gen_random_uuid(), id, company_id, datetime, price, created_at, updated_at, notes FROM price_updates;
    SQL
  end

  def down
    create_table :price_updates_old do |t|
      t.bigint :company_id
      t.datetime :datetime
      t.decimal :price, precision: 15, scale: 2
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.text :notes
    end
    add_index :price_updates_old, :company_id

    # Copy data (UUIDs will be lost)
    execute <<-SQL
      INSERT INTO price_updates_old (company_id, datetime, price, created_at, updated_at, notes)
      SELECT company_id, datetime, price, created_at, updated_at, notes FROM price_updates;
    SQL
  end
end
