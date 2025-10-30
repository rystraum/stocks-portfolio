class AddUrlsToCompanies < ActiveRecord::Migration[6.1]
  def change
    add_column :companies, :urls, :json
  end
end
