# frozen_string_literal: true

class CreatePriceMoveInsights < ActiveRecord::Migration[7.2]
  def change
    create_table :price_move_insights, id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
      t.references :company, type: :uuid, null: false, foreign_key: true
      t.date :move_date, null: false
      t.decimal :pct_change, precision: 10, scale: 4
      t.decimal :close_price, precision: 15, scale: 2
      t.integer :range_days, null: false
      t.text :explanation
      t.jsonb :news_items, default: []
      t.jsonb :search_queries, default: []
      t.timestamps

      t.index %i[company_id move_date], unique: true
    end
  end
end
