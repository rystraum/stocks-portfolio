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
          ['ALI', 'BUY', 500,  16_582.05, 'May 1, 2017'],
          ['BPI', 'BUY', 100,  9_564.03, 'May 1, 2017'],
          ['PSE', 'BUY', 2, 797.25, 'May 1, 2017'],
          ['URC', 'BUY', 30, 5_153.17, 'May 1, 2017'],
          ['PHN', 'BUY', 300, 3_442.92, 'May 2, 2017'],
          ['PIZZA', 'BUY', 200, 2_738.81, 'May 9, 2017'],
          ['ALI', 'BUY', 100, 3_912.98, 'May 17, 2017'],
          ['GMA7', 'BUY', 300, 1_852.68, 'May 26, 2017'],
          ['BPI', 'BUY', 40,  4_287.04,  'Jun 6, 2017'],
          ['MER', 'BUY', 10,  2_652.79,  'Jun 19, 2017'],
          ['DMC', 'BUY', 200,  2_954.84,  'Jun 19, 2017'],
          ['EDC', 'BUY', 500,  2_952.85,  'Jul 12, 2017'],
          ['PSE', 'BUY', 20, 4_855.12, 'Jul 28, 2017'],
          ['GMA7', 'BUY', 400, 2_366.75, 'Nov 23, 2017'],
          ['ALI', 'BUY', 100, 4_293.04, 'Nov 23, 2017'],
          ['FGENF', 'BUY', 40,  4_343.05,  'Jan 25, 2018'],
          ['SMC2I', 'BUY', 30,  2_362.75,  'Feb 13, 2018'],
          ['FBP2', 'BUY', 10,  9_929.21,  'May 10, 2018'],
          ['DMC', 'BUY', 100,  1_046.55,  'Jun 25, 2018'],
          ['FGENF', 'SELL', 40, 4_000.00,  'Jul 20, 2018'],
          ['GLOPP', 'BUY', 10,  5_093.16,  'Aug 3, 2018'],
          ['EDC', 'SELL', 500,  3_592.34,  'Nov 5, 2018'],
          ['SMC2I', 'BUY', 60,  4_433.06,  'Nov 26, 2018'],
          ['GMA7', 'BUY', 400,  2_374.75,  'Apr 1, 2019'],
          ['DMC', 'BUY', 800, 5_223.18, 'Dec 2, 2019']
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
