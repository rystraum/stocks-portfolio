# frozen_string_literal: true

class Activity < ApplicationRecord
  belongs_to :company

  validates :number_of_shares, presence: true
  validates :activity_type, presence: true

  scope :buy, -> { where(activity_type: 'BUY') }
  scope :sell, -> { where(activity_type: 'SELL') }

  def adjust(sum)
    is_buy? ? sum + number_of_shares : sum - number_of_shares
  end

  def cost_per_share
    total_price / number_of_shares
  end

  protected

  def is_buy?
    activity_type == 'BUY'
  end
end
