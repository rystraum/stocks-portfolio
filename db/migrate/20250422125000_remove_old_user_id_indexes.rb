class RemoveOldUserIdIndexes < ActiveRecord::Migration[6.0]
  def up
    remove_index :activities, name: :index_activities_on_old_user_id if index_exists?(:activities, :old_user_id, name: :index_activities_on_old_user_id)
    remove_index :cash_dividends, name: :index_cash_dividends_on_old_user_id if index_exists?(:cash_dividends, :old_user_id, name: :index_cash_dividends_on_old_user_id)
    remove_index :stock_dividends, name: :index_stock_dividends_on_old_user_id if index_exists?(:stock_dividends, :old_user_id, name: :index_stock_dividends_on_old_user_id)
    remove_index :converted_announcements, name: :index_converted_announcements_on_old_user_id if index_exists?(:converted_announcements, :old_user_id, name: :index_converted_announcements_on_old_user_id)
  end

  def down
    add_index :activities, :old_user_id, name: :index_activities_on_old_user_id unless index_exists?(:activities, :old_user_id, name: :index_activities_on_old_user_id)
    add_index :cash_dividends, :old_user_id, name: :index_cash_dividends_on_old_user_id unless index_exists?(:cash_dividends, :old_user_id, name: :index_cash_dividends_on_old_user_id)
    add_index :stock_dividends, :old_user_id, name: :index_stock_dividends_on_old_user_id unless index_exists?(:stock_dividends, :old_user_id, name: :index_stock_dividends_on_old_user_id)
    add_index :converted_announcements, :old_user_id, name: :index_converted_announcements_on_old_user_id unless index_exists?(:converted_announcements, :old_user_id, name: :index_converted_announcements_on_old_user_id)
  end
end
