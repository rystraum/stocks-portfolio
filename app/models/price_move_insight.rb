# frozen_string_literal: true

class PriceMoveInsight < ApplicationRecord
  belongs_to :company

  scope :latest_first, -> { order(move_date: :desc) }
end
