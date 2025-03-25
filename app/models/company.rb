# frozen_string_literal: true

class Company < ApplicationRecord
  validates :ticker, uniqueness: true, presence: true
  has_many :activities
  has_many :stock_dividends
  has_many :cash_dividends
  has_many :price_updates
  has_many :dividend_announcements

  scope :alphabetical, -> { order(:ticker) }
  scope :active, -> { where(inactive: false) }

  def to_s
    "#{ticker} [#{id}]"
  end

  def last_price
    @last_price ||= price_updates.order('datetime desc').first&.price || 0
  end

  def last_price_timestamp
    @last_price_timestamp ||= price_updates.order('datetime desc').first&.datetime&.to_datetime || DateTime.now
  end

  def history(user)
    @history ||= (activities + stock_dividends + cash_dividends).sort_by do |thing|
      if thing.is_a?(Activity)
        thing.date
      else
        (thing.ex_date.blank? ? thing.pay_date : thing.ex_date)
      end
    end
  end

  def can_update_from_pse?
    !pse_company_id.blank? && !pse_security_id.blank?
  end

  def pse_url
    return "" if pse_company_id.blank?
    "https://edge.pse.com.ph/companyPage/stockData.do?cmpy_id=#{pse_company_id}"
  end
end
