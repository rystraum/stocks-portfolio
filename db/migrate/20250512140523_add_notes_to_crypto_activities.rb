class AddNotesToCryptoActivities < ActiveRecord::Migration[6.1]
  def change
    add_column :crypto_activities, :notes, :text
  end
end
