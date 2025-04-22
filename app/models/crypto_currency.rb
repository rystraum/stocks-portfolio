class CryptoCurrency < ApplicationRecord
  self.primary_key = :id
  validates :name, presence: true
  validates :ticker, presence: true, uniqueness: true
  validates :decimal_places, presence: true

  scope :alphabetical, -> { order(:ticker) }
end
