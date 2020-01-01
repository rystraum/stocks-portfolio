# frozen_string_literal: true

class CreateActivities < ActiveRecord::Migration[5.2]
  def change
    create_table :activities do |t|
      t.references :company, foreign_key: true
      t.string :activity_type, index: true
      t.integer :number_of_shares
      t.decimal :total_price, precision: 15, scale: 2

      t.timestamps
    end
  end
end
