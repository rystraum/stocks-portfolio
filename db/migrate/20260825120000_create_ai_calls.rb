# frozen_string_literal: true

class CreateAiCalls < ActiveRecord::Migration[7.2]
  def change
    create_table :ai_calls, id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
      t.string :purpose
      t.string :model
      t.text :prompt
      t.text :response_body
      t.string :status
      t.text :error_message
      t.timestamps
    end
  end
end
