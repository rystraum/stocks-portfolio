class CreateConvertedAnnouncements < ActiveRecord::Migration[6.1]
  def change
    create_table :converted_announcements do |t|
      t.references :dividend_announcement
      t.references :user
      t.references :cash_dividend, null: true

      t.timestamps
    end

    add_index :converted_announcements, [:dividend_announcement_id, :user_id], unique: true, name: 'index_converted_dx_user_id'
  end
end
