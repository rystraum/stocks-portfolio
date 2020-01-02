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
          ['ALI',  158.76, 'Oct 2, 2018',  'Sep 3, 2018'],
          ['PHN',  118.80, 'Apr 6, 2018',  ''],
          ['ALI',  158.76, 'Apr 3, 2018',  ''],
          ['ALI',  129.60, 'Sep 15, 2017',  '']
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
