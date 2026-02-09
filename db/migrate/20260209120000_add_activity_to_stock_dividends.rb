# frozen_string_literal: true

class AddActivityToStockDividends < ActiveRecord::Migration[7.2]
  def change
    add_reference :stock_dividends, :activity, type: :uuid, foreign_key: true
  end
end
