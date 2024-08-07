# frozen_string_literal: true

class CashDividend < ApplicationRecord
  validates :amount, presence: true
  validates :pay_date, presence: true
  validates :ex_date, presence: true, on: :create

  belongs_to :user
  belongs_to :company

  serialize :meta, Hash
  store_accessor :meta, :dividend_per_share
  store_accessor :meta, :stocks_at_ex_date

  before_update :set_meta

  def display_date
    if ex_date.blank?
      "EX: UNKNOWN <br> PAY: #{pay_date.to_formatted_s(:long)}"
    else
      "EX: #{ex_date.to_formatted_s(:long)} <br> PAY: #{pay_date.to_formatted_s(:long)}"
    end
  end

  def last_price
    company.price_updates.where('date(datetime) <= ?', ex_date).order('datetime desc').first
  end

  def update_dps(val, force = false)
    update(dividend_per_share: val) if dividend_per_share.blank? || force
  end

  def update_stocks(val, force = false)
    update(stocks_at_ex_date: val) if stocks_at_ex_date.blank? || force
  end

  def set_meta(force = false)
    return if ex_date.blank?
    return if dividend_per_share.present? && stocks_at_ex_date.present? && !force

    ac = ActivitiesCalculator.new(company.activities.where('date < ?', ex_date).where(user: user))
    current_shares = ac.ending_shares
    
    self.dividend_per_share = amount / current_shares
    self.stocks_at_ex_date = current_shares
  end
end
