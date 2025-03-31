class AddDividendFrequencyToCompanies < ActiveRecord::Migration[6.1]
  def change
    add_column :companies, :dividend_frequency_months, :int
  end
end
