# frozen_string_literal: true

class AddUpstreamReferenceToCryptoActivities < ActiveRecord::Migration[7.2]
  def change
    add_column :crypto_activities, :upstream_source, :string
    add_column :crypto_activities, :upstream_trade_id, :string

    # Trade ids are unique per exchange; partial index so manually-entered
    # activities (NULL upstream) don't collide and aren't constrained.
    add_index :crypto_activities, %i[upstream_source upstream_trade_id],
              unique: true,
              where: "upstream_trade_id IS NOT NULL",
              name: "index_crypto_activities_on_upstream"
  end
end
