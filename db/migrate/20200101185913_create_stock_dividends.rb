class CreateStockDividends < ActiveRecord::Migration[5.2]
  def change
    create_table :stock_dividends do |t|
      t.references :company, foreign_key: true
      t.string :amount
      t.date :pay_date
      t.date :ex_date

      t.timestamps
    end
  end
end
