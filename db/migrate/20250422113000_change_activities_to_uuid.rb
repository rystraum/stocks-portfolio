class ChangeActivitiesToUuid < ActiveRecord::Migration[6.0]
  def up
    enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')

    # Step 2: Create new table with UUID primary key, retaining all columns and old_id
    create_table :activities_new, id: :uuid do |t|
      t.bigint :old_id
      t.bigint :company_id  # companies is still integer
      t.string :activity_type
      t.integer :number_of_shares
      t.decimal :total_price, precision: 15, scale: 2
      t.date :date
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.decimal :charges, precision: 15, scale: 4
      t.bigint :user_id     # users is still bigint
      t.text :notes
    end
    add_index :activities_new, :company_id
    add_index :activities_new, :user_id
    add_index :activities_new, :activity_type

    # Step 3: Copy data from original table and assign new UUIDs
    execute <<-SQL
      INSERT INTO activities_new (id, old_id, company_id, activity_type, number_of_shares, total_price, date, created_at, updated_at, charges, user_id, notes)
      SELECT gen_random_uuid(), id, company_id, activity_type, number_of_shares, total_price, date, created_at, updated_at, charges, user_id, notes FROM activities;
    SQL
  end

  def down
    create_table :activities_old do |t|
      t.date :date
      t.integer :company_id
      t.string :activity_type
      t.integer :number_of_shares
      t.decimal :total_price, precision: 15, scale: 2
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.decimal :charges, precision: 15, scale: 4
      t.bigint :user_id
      t.text :notes
    end
    add_index :activities_old, :company_id
    add_index :activities_old, :user_id
    add_index :activities_old, :activity_type

    # Copy data (UUIDs will be lost)
    execute <<-SQL
      INSERT INTO activities_old (date, company_id, activity_type, number_of_shares, total_price, created_at, updated_at, charges, user_id, notes)
      SELECT date, company_id, activity_type, number_of_shares, total_price, created_at, updated_at, charges, user_id, notes FROM activities;
    SQL
  end
end
