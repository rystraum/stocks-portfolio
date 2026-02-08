# frozen_string_literal: true

class AddNameToCompanies < ActiveRecord::Migration[6.1]
  def change
    add_column :companies, :name, :string
  end
end
