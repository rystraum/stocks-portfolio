class CreateDividendAnnouncements < ActiveRecord::Migration[6.1]
  def change
    create_table :dividend_announcements do |t|
      t.references :company, null: false, foreign_key: true
      t.string :share_class
      t.string :dividend_type
      t.decimal :amount
      t.date :ex_date
      t.date :record_date
      t.date :payout_date
      t.string :circular_number
      t.timestamps
    end

    add_index :dividend_announcements, :circular_number, unique: true
  end
end
