class AddDatasourceToCryptoCurrencies < ActiveRecord::Migration[6.1]
  def change
    add_column :crypto_currencies, :datasource, :string, default: "https://api.pro.coins.ph/"
  end
end
