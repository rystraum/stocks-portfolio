class AddNotesToActivities < ActiveRecord::Migration[6.0]
  def change
    add_column :activities, :notes, :text
  end
end
