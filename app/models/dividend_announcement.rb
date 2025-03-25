class DividendAnnouncement < ApplicationRecord
  belongs_to :company
  validates :circular_number, uniqueness: true
end
