# frozen_string_literal: true

class ReaddUserIdIndexes < ActiveRecord::Migration[6.0]
  def up
    add_index :activities, :user_id, name: :index_activities_on_user_id unless index_exists?(:activities, :user_id,
                                                                                             name: :index_activities_on_user_id,)
    add_index :cash_dividends, :user_id, name: :index_cash_dividends_on_user_id unless index_exists?(:cash_dividends, :user_id,
                                                                                                     name: :index_cash_dividends_on_user_id,)
    add_index :stock_dividends, :user_id, name: :index_stock_dividends_on_user_id unless index_exists?(:stock_dividends, :user_id,
                                                                                                       name: :index_stock_dividends_on_user_id,)
  end

  def down
    remove_index :activities, name: :index_activities_on_user_id if index_exists?(:activities, :user_id, name: :index_activities_on_user_id)
    remove_index :cash_dividends, name: :index_cash_dividends_on_user_id if index_exists?(:cash_dividends, :user_id,
                                                                                          name: :index_cash_dividends_on_user_id,)
    remove_index :stock_dividends, name: :index_stock_dividends_on_user_id if index_exists?(:stock_dividends, :user_id,
                                                                                            name: :index_stock_dividends_on_user_id,)
  end
end
