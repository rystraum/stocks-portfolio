# frozen_string_literal: true

class ChangeUsersToUuid < ActiveRecord::Migration[6.0]
  def up
    enable_extension "pgcrypto" unless extension_enabled?("pgcrypto")

    # Step 2: Create new table with UUID primary key, retaining all columns and old_id
    create_table :users_new, id: :uuid do |t|
      t.bigint :old_id
      t.string :email, default: "", null: false
      t.string :encrypted_password, default: "", null: false
      t.string :reset_password_token
      t.datetime :reset_password_sent_at
      t.datetime :remember_created_at
      t.datetime :created_at, precision: 6, null: false
      t.datetime :updated_at, precision: 6, null: false
    end
    add_index :users_new, :email, unique: true
    add_index :users_new, :reset_password_token, unique: true

    # Step 3: Copy data from original table and assign new UUIDs
    execute <<-SQL
      INSERT INTO users_new (id, old_id, email, encrypted_password, reset_password_token, reset_password_sent_at, remember_created_at, created_at, updated_at)
      SELECT gen_random_uuid(), id, email, encrypted_password, reset_password_token, reset_password_sent_at, remember_created_at, created_at, updated_at FROM users;
    SQL
  end

  def down
    create_table :users_old do |t|
      t.string :email, default: "", null: false
      t.string :encrypted_password, default: "", null: false
      t.string :reset_password_token
      t.datetime :reset_password_sent_at
      t.datetime :remember_created_at
      t.datetime :created_at, precision: 6, null: false
      t.datetime :updated_at, precision: 6, null: false
    end
    add_index :users_old, :email, unique: true
    add_index :users_old, :reset_password_token, unique: true

    # Copy data (UUIDs will be lost)
    execute <<-SQL
      INSERT INTO users_old (email, encrypted_password, reset_password_token, reset_password_sent_at, remember_created_at, created_at, updated_at)
      SELECT email, encrypted_password, reset_password_token, reset_password_sent_at, remember_created_at, created_at, updated_at FROM users;
    SQL
  end
end
