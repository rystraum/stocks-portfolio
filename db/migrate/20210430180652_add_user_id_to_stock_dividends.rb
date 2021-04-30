class AddUserIdToStockDividends < ActiveRecord::Migration[6.0]
  def change
    add_reference :stock_dividends, :user, null: true, foreign_key: true

    reversible do |dir|
      dir.up do
        StockDividend.update_all(user_id: User.first.id)
      end
    end
  end
end
