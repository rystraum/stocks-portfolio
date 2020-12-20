# frozen_string_literal: true

class CashDividend < ApplicationRecord
  validates :amount, presence: true
  validates :pay_date, presence: true
  validates :ex_date, presence: true, on: :create

  belongs_to :company

  serialize :meta, Hash
  store_accessor :meta, :dividend_per_share
  store_accessor :meta, :stocks_at_ex_date

  before_create :set_meta

  def display_date
    if ex_date.blank?
      "EX: UNKNOWN <br> PAY: #{pay_date.to_formatted_s(:long)}"
    else
      "EX: #{ex_date.to_formatted_s(:long)} <br> PAY: #{pay_date.to_formatted_s(:long)}"
    end
  end

  def update_dps(val, force = false)
    update(dividend_per_share: val) if dividend_per_share.blank? || force
  end

  def update_stocks(val, force = false)
    update(stocks_at_ex_date: val) if stocks_at_ex_date.blank? || force
  end

  private

  def set_meta
    return if ex_date.blank?
    return unless dividend_per_share.blank? || stocks_at_ex_date.blank?

    ac = ActivitiesCalculator.new(company.activities.where('date < ?', ex_date))
    current_shares = ac.ending_shares
    update(
      dividend_per_share: amount / current_shares,
      stocks_at_ex_date: current_shares
    )
  end
end
