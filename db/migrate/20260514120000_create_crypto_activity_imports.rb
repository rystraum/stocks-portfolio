# frozen_string_literal: true

class CreateCryptoActivityImports < ActiveRecord::Migration[7.2]
  def change
    create_table :crypto_activity_imports, id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
      t.uuid :user_id, null: false
      t.string :filename, null: false
      t.integer :status, default: 0, null: false
      t.timestamps
    end

    create_table :crypto_activity_import_items, id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
      t.uuid :crypto_activity_import_id, null: false
      t.string :order_id, null: false
      t.uuid :crypto_currency_id
      t.integer :activity_type
      t.decimal :crypto_amount, precision: 30, scale: 20
      t.decimal :fiat_amount, precision: 18, scale: 2
      t.decimal :fee_crypto, precision: 30, scale: 20, default: "0.0"
      t.decimal :fee_fiat, precision: 18, scale: 2, default: "0.0"
      t.date :activity_date
      t.text :notes
      t.integer :resolution, default: 0
      t.uuid :duplicate_crypto_activity_id
      t.jsonb :raw_rows, default: []
      t.timestamps
    end

    add_reference :crypto_activities, :crypto_activity_import, type: :uuid, foreign_key: true, index: true

    add_index :crypto_activity_imports, :user_id
    add_index :crypto_activity_import_items, :crypto_activity_import_id
    add_index :crypto_activity_import_items, :duplicate_crypto_activity_id
  end
end
