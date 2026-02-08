# frozen_string_literal: true

class ChangeCryptoCurrenciesToUuid < ActiveRecord::Migration[6.0]
  def up
    enable_extension "pgcrypto" unless extension_enabled?("pgcrypto")

    # Create new table with UUID as primary key
    create_table :crypto_currencies_new, id: :uuid do |t|
      t.string :name, null: false
      t.string :ticker, null: false
      t.integer :last_price
      t.datetime :last_price_at
      t.integer :decimal_places, null: false, default: 8
      t.timestamps
    end
    add_index :crypto_currencies_new, :ticker, unique: true

    # Copy data
    execute <<-SQL
      INSERT INTO crypto_currencies_new (id, name, ticker, last_price, last_price_at, decimal_places, created_at, updated_at)
      SELECT gen_random_uuid(), name, ticker, last_price, last_price_at, decimal_places, created_at, updated_at FROM crypto_currencies;
    SQL

    # Drop old table and rename new one
    drop_table :crypto_currencies
    rename_table :crypto_currencies_new, :crypto_currencies
  end

  def down
    create_table :crypto_currencies_old do |t|
      t.string :name, null: false
      t.string :ticker, null: false
      t.integer :last_price
      t.datetime :last_price_at
      t.integer :decimal_places, null: false, default: 8
      t.timestamps
    end
    add_index :crypto_currencies_old, :ticker, unique: true

    # Copy data (UUIDs will be lost)
    execute <<-SQL
      INSERT INTO crypto_currencies_old (name, ticker, last_price, last_price_at, decimal_places, created_at, updated_at)
      SELECT name, ticker, last_price, last_price_at, decimal_places, created_at, updated_at FROM crypto_currencies;
    SQL

    drop_table :crypto_currencies
    rename_table :crypto_currencies_old, :crypto_currencies
  end
end
