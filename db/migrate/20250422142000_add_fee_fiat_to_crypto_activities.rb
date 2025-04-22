class AddFeeFiatToCryptoActivities < ActiveRecord::Migration[6.0]
  def change
    add_column :crypto_activities, :fee_fiat, :decimal, precision: 18, scale: 2, default: 0
  end
end
