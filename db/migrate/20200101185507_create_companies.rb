# frozen_string_literal: true

class CreateCompanies < ActiveRecord::Migration[5.2]
  def change
    create_table :companies do |t|
      t.string :ticker, index: { unique: true }
      t.string :industry, index: true

      t.timestamps
    end

    reversible do |dir|
      dir.up do
        [
          ['ALI', 'Real Estate'],
          %w[BPI Finance],
          %w[DMC Holding],
          %w[FBP2 Preferred],
          %w[GLOPP Preferred],
          %w[GMA7 Services],
          %w[MER Industrial],
          %w[PHN Holding],
          %w[PIZZA Services],
          %w[PSE Finance],
          %w[SMC2I Preferred],
          %w[URC Industrial],
          %w[EDC Industrial],
          %w[FGENF Preferred]
        ].each do |arr|
          ticker, industry = arr
          c = Company.where(ticker: ticker).first_or_create
          c.update(industry: industry)
        end
      end
    end
  end
end
