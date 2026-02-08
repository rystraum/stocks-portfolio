# frozen_string_literal: true

class AddChargesToActivities < ActiveRecord::Migration[5.2]
  def change
    add_column :activities, :charges, :decimal, precision: 15, scale: 4
  end
end
