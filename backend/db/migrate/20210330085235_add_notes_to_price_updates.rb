# frozen_string_literal: true

class AddNotesToPriceUpdates < ActiveRecord::Migration[6.0]
  def change
    add_column :price_updates, :notes, :text
  end
end
