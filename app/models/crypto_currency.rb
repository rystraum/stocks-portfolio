class CryptoCurrency < ApplicationRecord
  self.primary_key = :id
  validates :name, presence: true
  validates :ticker, presence: true, uniqueness: true

  scope :alphabetical, -> { order(:ticker) }
end
