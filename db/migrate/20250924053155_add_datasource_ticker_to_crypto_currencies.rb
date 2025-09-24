class AddDatasourceTickerToCryptoCurrencies < ActiveRecord::Migration[6.1]
  def change
    add_column :crypto_currencies, :datasource_ticker, :string
  end
end
