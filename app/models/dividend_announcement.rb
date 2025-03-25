class DividendAnnouncement < ApplicationRecord
  belongs_to :company
  validates :circular_number, uniqueness: true

  scope :in_the_future, -> { where('payout_date >= ?', Date.today) }
  scope :within_the_year, -> { where('payout_date >= ? AND payout_date < ?', Date.today.beginning_of_year, Date.today.end_of_year) }
end
