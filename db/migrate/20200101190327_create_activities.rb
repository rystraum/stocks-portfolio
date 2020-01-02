# frozen_string_literal: true

class CreateActivities < ActiveRecord::Migration[5.2]
  def change
    create_table :activities do |t|
      t.date :date
      t.references :company, foreign_key: true
      t.string :activity_type, index: true
      t.integer :number_of_shares
      t.decimal :total_price, precision: 15, scale: 2

      t.timestamps
    end

    reversible do |dir|
      dir.up do
        [
          ['ALI', 'BUY', 500, 16_582.05, 'May 1, 2017']
        ].each do |arr|
          ticker, type, number_of_shares, total_price, date = arr
          company = Company.find_by(ticker: ticker)
          formatted_date = Date.strptime(date, '%h %d, %Y')
          Activity.where(
            company: company,
            activity_type: type,
            number_of_shares: number_of_shares,
            total_price: total_price,
            date: formatted_date
          ).first_or_create
        end
      end
    end
  end
end
