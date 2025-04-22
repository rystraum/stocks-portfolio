class CreateCryptoActivities < ActiveRecord::Migration[6.0]
  def change
    enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')
    create_table :crypto_activities, id: :uuid do |t|
      t.uuid :user_id, null: false
      t.uuid :crypto_currency_id, null: false
      t.integer :activity_type, null: false # 0: buy, 1: sell
      t.decimal :crypto_amount, precision: 18, scale: 10, null: false
      t.decimal :fiat_amount, precision: 18, scale: 2, null: false
      t.string :fiat_currency, null: false
      t.decimal :fee_crypto, precision: 18, scale: 10, default: 0
      t.date :activity_date, null: false
      t.timestamps
    end
    add_index :crypto_activities, :user_id
    add_index :crypto_activities, :crypto_currency_id
    add_index :crypto_activities, :activity_type
    add_foreign_key :crypto_activities, :users, column: :user_id
    add_foreign_key :crypto_activities, :crypto_currencies, column: :crypto_currency_id
  end
end
