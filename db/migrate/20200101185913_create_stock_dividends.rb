# frozen_string_literal: true

class CreateStockDividends < ActiveRecord::Migration[5.2]
  def change
    create_table :stock_dividends do |t|
      t.references :company, foreign_key: true
      t.integer :amount
      t.date :pay_date
      t.date :ex_date

      t.timestamps
    end

    reversible do |dir|
      dir.up do
        StockDividend.where(
          company: Company.find_by(ticker: "PHN"),
          amount: 30,
          pay_date: Date.new(2017, 6, 30),
        ).first_or_create
      end
    end
  end
end
