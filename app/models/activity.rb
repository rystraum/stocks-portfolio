# frozen_string_literal: true

class Activity < ApplicationRecord
  belongs_to :company

  validates :date, presence: true, on: :create
  validates :number_of_shares, presence: true
  validates :activity_type, presence: true

  scope :buy, -> { where(activity_type: 'BUY') }
  scope :sell, -> { where(activity_type: 'SELL') }

  def adjust(sum)
    return sum + number_of_shares if is_buy?
    return sum - number_of_shares if is_sell?

    sum
  end

  def cost_per_share
    return 0 unless is_buy? && is_sell?

    total_price / number_of_shares
  end

  protected

  def is_buy?
    activity_type == 'BUY'
  end

  def is_sell?
    activity_type == 'SELL'
  end
end
