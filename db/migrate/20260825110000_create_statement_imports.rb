# frozen_string_literal: true

class CreateStatementImports < ActiveRecord::Migration[7.2]
  def change
    create_table :statement_imports, id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
      t.references :user, type: :uuid, null: false, foreign_key: true
      t.string :filename
      t.string :content_hash
      t.integer :status, default: 0, null: false
      t.string :statement_period
      t.text :error_message
      t.timestamps

      t.index %i[user_id content_hash], unique: true
    end

    create_table :statement_import_items, id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
      t.references :statement_import, type: :uuid, null: false, foreign_key: true
      t.references :company, type: :uuid, foreign_key: true
      t.integer :item_type, default: 0, null: false
      t.boolean :selected, default: true, null: false
      t.boolean :duplicate, default: false, null: false
      t.date :date
      t.string :ticker
      t.integer :shares
      t.decimal :price, precision: 15, scale: 4
      t.decimal :amount, precision: 15, scale: 2
      t.decimal :charges, precision: 15, scale: 4
      t.date :ex_date
      t.string :ref
      t.text :particulars
      t.string :note
      t.timestamps
    end
  end
end
