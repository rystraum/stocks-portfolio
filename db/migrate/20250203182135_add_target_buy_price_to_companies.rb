# frozen_string_literal: true

class AddTargetBuyPriceToCompanies < ActiveRecord::Migration[6.1]
  def change
    add_column :companies, :target_buy_price, :decimal, precision: 15, scale: 2
  end
end
