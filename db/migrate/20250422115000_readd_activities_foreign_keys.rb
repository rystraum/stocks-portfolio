# frozen_string_literal: true

class ReaddActivitiesForeignKeys < ActiveRecord::Migration[6.0]
  def up
    add_foreign_key :activities, :companies
    add_foreign_key :activities, :users
  end

  def down
    remove_foreign_key :activities, :companies
    remove_foreign_key :activities, :users
  end
end
