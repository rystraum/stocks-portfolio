# frozen_string_literal: true

class Activity < ApplicationRecord
  belongs_to :user
  belongs_to :company

  validates :date, presence: true, on: :create
  validates :number_of_shares, presence: true
  validates :activity_type, presence: true

  scope :buy, -> { where(activity_type: "BUY") }
  scope :sell, -> { where(activity_type: "SELL") }

  after_commit :update_dividends_after_this_activity

  def adjust(sum, include_planned: false)
    return sum + number_of_shares if is_buy?
    return sum - number_of_shares if is_sell?
    return sum + number_of_shares if include_planned && activity_type == "PLANNED BUY"
    return sum - number_of_shares if include_planned && activity_type == "PLANNED SELL"

    sum
  end

  def cost_per_share(include_planned: false)
    return 0 if !include_planned && is_buy? && is_sell?

    total_price / number_of_shares
  end

  def is_buy?
    activity_type == "BUY"
  end

  def is_sell?
    activity_type == "SELL"
  end

  def is_planned?
    activity_type.include? "PLANNED"
  end

  def convert_planned!
    return update(activity_type: "BUY") if activity_type == "PLANNED BUY"
    return update(activity_type: "SELL") if activity_type == "PLANNED SELL"
  end

  private

  def update_dividends_after_this_activity
    cash_dividends = company.cash_dividends.where("created_at > ?", created_at)
    cash_dividends.map(&:save)
  end
end
