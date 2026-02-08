# frozen_string_literal: true

class CreatePriceUpdates < ActiveRecord::Migration[5.2]
  def change
    create_table :price_updates do |t|
      t.references :company, foreign_key: true
      t.datetime :datetime, index: true
      t.decimal :price, precision: 15, scale: 2

      t.timestamps
    end

    reversible do |dir|
      dir.up do
        timestamp = DateTime.new(2020, 1, 2, 0, 0)
        [
          ["ALI", 45.50],
          ["BPI", 87.90],
          ["DMC", 6.61],
          ["FBP2", 997.00],
          ["GLOPP", 500.00],
          ["GMA7", 5.33],
          ["MER", 317.00],
          ["PHN", 10.06],
          ["PIZZA", 9.90],
          ["PSE", 175.00],
          ["SMC2I", 75.20],
          ["URC", 145.00],
          ["EDC", 7.25],
          ["FGENF", 80.00],
        ].each do |arr|
          ticker, price = arr
          PriceUpdate.where(
            company: Company.find_by(ticker: ticker),
            datetime: timestamp,
            price: price,
          ).first_or_create
        end
      end
    end
  end
end
