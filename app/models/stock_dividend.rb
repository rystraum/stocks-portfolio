# frozen_string_literal: true

class StockDividend < ApplicationRecord
  belongs_to :user
  belongs_to :company
  belongs_to :activity, optional: true

  belongs_to :last_price_update, class_name: "PriceUpdate", optional: true

  after_commit :create_buy_activity, on: :create

  def display_date
    if ex_date.blank?
      "EX: UNKNOWN <br> PAY: #{pay_date.to_formatted_s(:long)}"
    else
      "EX: #{ex_date.to_formatted_s(:long)} <br> PAY: #{pay_date.to_formatted_s(:long)}"
    end
  end

  def last_price
    return last_price_update if last_price_update.present?

    lpu = company.price_updates.where("date(datetime) <= ?", ex_date).order("datetime desc").first
    self.last_price_update = lpu
    save

    return lpu
  end

  def create_buy_activity
    return if pay_date.blank? || amount.blank?
    return if activity_id.present?

    created_activity = build_activity
    created_activity.assign_attributes(
      user: user,
      company: company,
      activity_type: "BUY",
      number_of_shares: amount,
      total_price: 0,
      date: pay_date,
    )
    created_activity.save!
    update(activity_id: created_activity.id)

    update_cash_dividend_meta_after_ex_date
  end

  private

  def update_cash_dividend_meta_after_ex_date
    return if ex_date.blank?

    company.cash_dividends.where(user: user).where("ex_date > ?", ex_date).find_each do |cash_dividend|
      cash_dividend.set_meta!(force: true)
    end
  end
end
