# frozen_string_literal: true

class AddInactiveToCompanies < ActiveRecord::Migration[5.2]
  def change
    add_column :companies, :inactive, :boolean, default: false
  end
end
