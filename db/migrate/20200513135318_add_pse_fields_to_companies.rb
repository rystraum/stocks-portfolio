class AddPseFieldsToCompanies < ActiveRecord::Migration[5.2]
  def change
    add_column :companies, :pse_security_id, :string
    add_column :companies, :pse_company_id, :string
  end
end
