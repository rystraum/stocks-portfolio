class IncreaseCryptoCurrencyLastPricePrecision < ActiveRecord::Migration[6.0]
  def change
    change_column :crypto_currencies, :last_price, :decimal, precision: 30, scale: 20
    remove_column :crypto_currencies, :decimal_places
  end
end
