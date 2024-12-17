# frozen_string_literal: true

class StockDividend < ApplicationRecord
  belongs_to :user
  belongs_to :company

  belongs_to :last_price_update, class_name: 'PriceUpdate', foreign_key: :last_price_update_id

  def display_date
    if ex_date.blank?
      "EX: UNKNOWN <br> PAY: #{pay_date.to_formatted_s(:long)}"
    else
      "EX: #{ex_date.to_formatted_s(:long)} <br> PAY: #{pay_date.to_formatted_s(:long)}"
    end
  end

  def last_price
    return last_price_update if last_price_update.present?

    lpu = company.price_updates.where('date(datetime) <= ?', ex_date).order('datetime desc').first
    self.last_price_update = lpu
    save

    return lpu
  end
end
