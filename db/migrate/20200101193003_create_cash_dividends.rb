# frozen_string_literal: true

class CreateCashDividends < ActiveRecord::Migration[5.2]
  def change
    create_table :cash_dividends do |t|
      t.references :company, foreign_key: true
      t.decimal :amount, precision: 15, scale: 2
      t.date :pay_date
      t.date :ex_date

      t.timestamps
    end

    reversible do |dir|
      dir.up do
        [
          ['ALI', 163.80, 'Nov 29, 2019',  'Nov 11, 2019'],
          ['SMC2I', 96.22, 'Oct 4, 2019',  'Sep 17, 2019'],
          ['MER', 49.18, 'Sep 20, 2019', 'Aug 22, 2019'],
          ['FBP2', 127.28, 'Sep 13, 2019', 'Aug 16, 2019'],
          ['GLOPP',  117.01, 'Aug 22, 2019', 'Jul 23, 2019'],
          ['PIZZA',  18.00, 'Aug 14, 2019', 'Jul 16, 2019'],
          ['URC', 44.55, 'Jul 25, 2019', 'Jun 26, 2019'],
          ['SMC2I', 96.22, 'Jul 5, 2019',  'Jun 18, 2019'],
          ['BPI', 113.40, 'Jun 19, 2019',  'May 24, 2019'],
          ['FBP2',  127.28, 'Jun 14, 2019',  'May 20, 2019'],
          ['GMA7',  445.50, 'May 15, 2019',  'Apr 15, 2019'],
          ['PSE',  174.24, 'May 10, 2019',  'Apr 8, 2019'],
          ['DMC',  129.60, 'May 10, 2019',  'Apr 24, 2019'],
          ['MER',  95.35, 'Apr 24, 2019',  'Mar 19, 2019'],
          ['SMC2I', 96.22, 'Apr 5, 2019',  'Mar 19, 2019'],
          ['ALI',  163.80, 'Mar 29, 2019',  'Mar 8, 2019'],
          ['PHN',  118.80, 'Mar 29, 2019',  'Mar 18, 2019'],
          ['URC',  40.50, 'Mar 28, 2019', 'Mar 11, 2019'],
          ['FBP2', 127.28, 'Mar 13, 2019', 'Feb 15, 2019'],
          ['GLOPP', 117.01, 'Feb 22, 2019', 'Jan 23, 2019'],
          ['BPI', 113.40, 'Jan 29, 2019', 'Jan 3, 2019'],
          ['SMC2I', 96.22, 'Jan 11, 2019', 'Dec 18, 2018'],
          ['DMC', 129.60, 'Dec 18, 2018', 'Nov 29, 2018'],
          ['FBP2', 127.28, 'Dec 13, 2018', 'Nov 22, 2018'],
          ['SMC2I',  32.07, 'Oct 10, 2018',  'Sep 18, 2018'],
          ['PIZZA',  18.00, 'Oct 10, 2018',  'Sep 11, 2018'],
          ['ALI',  158.76, 'Oct 2, 2018',  'Sep 3, 2018'],
          ['MER',  47.80, 'Sep 24, 2018',  'Aug 23, 2018'],
          ['FBP2', 127.28, 'Sep 13, 2018', 'Aug 17, 2018'],
          ['GLOPP', 117.01, 'Aug 22, 2018', 'Aug 7, 2018'],
          ['BPI', 113.40, 'Jul 25, 2018', 'Jun 29, 2018'],
          ['FGENF',  144.00, 'Jul 25, 2018', 'Jun 29, 2018'],
          ['SMC2I',  32.07, 'Jul 6, 2018', 'Jun 18, 2018'],
          ['FBP2',  127.28, 'Jun 14, 2018',  ''],
          ['GMA7',  315.00, 'May 16, 2018',  'Apr 18, 2018'],
          ['MER',  72.58, 'Apr 25, 2018', 'Mar 23, 2018'],
          ['DMC',  86.40, 'Apr 6, 2018', ''],
          ['PHN',  118.80, 'Apr 6, 2018',  ''],
          ['SMC2I', 32.07, 'Apr 5, 2018',  ''],
          ['ALI',  158.76, 'Apr 3, 2018',  ''],
          ['URC',  85.05, 'Mar 22, 2018',  ''],
          ['PSE',  178.20, 'Mar 6, 2018',  ''],
          ['BPI',  113.40, 'Jan 19, 2018',  ''],
          ['MER',  80.32, 'Sep 22, 2017', ''],
          ['ALI',  129.60, 'Sep 15, 2017',  ''],
          ['BPI',  113.40, 'Jul 27, 2017',  ''],
          ['PIZZA', 18.00, 'Jun 30, 2017',  '']
        ].each do |arr|
          ticker, amount, pay_date, ex_date = arr
          company = Company.find_by(ticker: ticker)
          fpay_date = Date.strptime(pay_date, '%h %d, %Y')
          fex_date = ex_date.blank? ? nil : Date.strptime(ex_date, '%h %d, %Y')
          attrs = {
            company: company,
            amount: amount,
            pay_date: fpay_date
          }
          attrs[:ex_date] = fex_date unless ex_date.blank?

          CashDividend.where(attrs).first_or_create
        end
      end
    end
  end
end
