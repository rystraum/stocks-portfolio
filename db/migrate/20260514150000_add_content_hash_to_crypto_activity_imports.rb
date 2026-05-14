# frozen_string_literal: true

class AddContentHashToCryptoActivityImports < ActiveRecord::Migration[7.2]
  def change
    add_column :crypto_activity_imports, :content_hash, :string
    add_index :crypto_activity_imports, [:user_id, :content_hash], unique: true
  end
end
