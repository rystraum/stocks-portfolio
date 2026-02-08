# frozen_string_literal: true

class AddMetaToCashDividends < ActiveRecord::Migration[5.2]
  def change
    add_column :cash_dividends, :meta, :text
  end
end
