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
