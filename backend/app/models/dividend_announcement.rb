# frozen_string_literal: true

class DividendAnnouncement < ApplicationRecord
  belongs_to :company
  has_many :converted_announcements, dependent: :restrict_with_error

  validates :circular_number, uniqueness: true

  scope :ex_date_in_the_future, -> { where("ex_date >= ?", Time.zone.today) }
  scope :in_the_future, -> { where("payout_date >= ?", Time.zone.today) }
  scope :within_the_year, -> { where("payout_date >= ? AND payout_date < ?", Time.zone.today.beginning_of_year, Time.zone.today.end_of_year) }

  def pay_date
    payout_date
  end
end
