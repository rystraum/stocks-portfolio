class DividendAnnouncement < ApplicationRecord
  belongs_to :company
  has_many :converted_announcements

  validates :circular_number, uniqueness: true

  scope :ex_date_in_the_future, -> { where('ex_date >= ?', Date.today) }
  scope :in_the_future, -> { where('payout_date >= ?', Date.today) }
  scope :within_the_year, -> { where('payout_date >= ? AND payout_date < ?', Date.today.beginning_of_year, Date.today.end_of_year) }

  def pay_date
    payout_date
  end
end
