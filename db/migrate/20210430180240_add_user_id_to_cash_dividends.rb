# frozen_string_literal: true

class AddUserIdToCashDividends < ActiveRecord::Migration[6.0]
  def change
    add_reference :cash_dividends, :user, null: true, foreign_key: true

    reversible do |dir|
      dir.up do
        CashDividend.update_all(user_id: User.first.id)
      end
    end
  end
end
