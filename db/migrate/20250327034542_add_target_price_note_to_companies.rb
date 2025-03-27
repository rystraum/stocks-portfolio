class AddTargetPriceNoteToCompanies < ActiveRecord::Migration[6.1]
  def change
    add_column :companies, :target_price_note, :string
  end
end
