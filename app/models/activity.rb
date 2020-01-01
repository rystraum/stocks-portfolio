# frozen_string_literal: true

class Activity < ApplicationRecord
  belongs_to :company

  validates :number_of_shares, presence: true
  validates :activity_type, presence: true

  scope :buy, -> { where(activity_type: 'BUY') }
  scope :sell, -> { where(activity_type: 'SELL') }
end
