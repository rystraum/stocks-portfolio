# frozen_string_literal: true

class AiCall < ApplicationRecord
  scope :latest_first, -> { order(created_at: :desc) }
end
