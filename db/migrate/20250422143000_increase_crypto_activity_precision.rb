# frozen_string_literal: true

class IncreaseCryptoActivityPrecision < ActiveRecord::Migration[6.0]
  def change
    change_column :crypto_activities, :crypto_amount, :decimal, precision: 30, scale: 20
    change_column :crypto_activities, :fee_crypto, :decimal, precision: 30, scale: 20
  end
end
