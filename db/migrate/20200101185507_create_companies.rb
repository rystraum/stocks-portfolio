class CreateCompanies < ActiveRecord::Migration[5.2]
  def change
    create_table :companies do |t|
      t.string :ticker
      t.string :industry

      t.timestamps
    end
  end
end
