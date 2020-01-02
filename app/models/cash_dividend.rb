# frozen_string_literal: true

class CashDividend < ApplicationRecord
  validates :amount, presence: true
  validates :pay_date, presence: true

  belongs_to :company

  serialize :meta, Hash
  store_accessor :meta, :dividend_per_share
end
