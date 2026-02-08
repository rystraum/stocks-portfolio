# frozen_string_literal: true

class PopulateCompanyUuidInReferencingTables < ActiveRecord::Migration[6.0]
  def up
    add_column :activities, :company_uuid, :uuid
    add_column :cash_dividends, :company_uuid, :uuid
    add_column :dividend_announcements, :company_uuid, :uuid
    add_column :price_updates, :company_uuid, :uuid
    add_column :stock_dividends, :company_uuid, :uuid

    execute <<-SQL
      UPDATE activities SET company_uuid = companies_new.id FROM companies_new WHERE activities.company_id = companies_new.old_id;
      UPDATE cash_dividends SET company_uuid = companies_new.id FROM companies_new WHERE cash_dividends.company_id = companies_new.old_id;
      UPDATE dividend_announcements SET company_uuid = companies_new.id FROM companies_new WHERE dividend_announcements.company_id = companies_new.old_id;
      UPDATE price_updates SET company_uuid = companies_new.id FROM companies_new WHERE price_updates.company_id = companies_new.old_id;
      UPDATE stock_dividends SET company_uuid = companies_new.id FROM companies_new WHERE stock_dividends.company_id = companies_new.old_id;
    SQL
  end

  def down
    remove_column :activities, :company_uuid
    remove_column :cash_dividends, :company_uuid
    remove_column :dividend_announcements, :company_uuid
    remove_column :price_updates, :company_uuid
    remove_column :stock_dividends, :company_uuid
  end
end
