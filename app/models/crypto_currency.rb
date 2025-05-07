# frozen_string_literal: true

# == Schema Information
#
# Table name: crypto_currencies
#
#  id          :uuid             not null, primary key
#  name        :string           not null
#  ticker      :string           not null
#  last_price  :decimal(30, 20)
#  last_price_at :datetime
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class CryptoCurrency < ApplicationRecord
  self.primary_key = :id
  validates :name, presence: true
  validates :ticker, presence: true, uniqueness: true

  scope :alphabetical, -> { order(:ticker) }

  def to_s
    ticker
  end

  def to_param
    ticker
  end
end
