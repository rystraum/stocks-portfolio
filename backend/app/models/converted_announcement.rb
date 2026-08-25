# frozen_string_literal: true

# == Schema Information
#
# Table name: converted_announcements
#
#  id                   :integer          not null, primary key
#  dividend_announcement_id :integer
#  user_id              :integer
#  cash_dividend_id     :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

class ConvertedAnnouncement < ApplicationRecord
  belongs_to :dividend_announcement
  belongs_to :user
  belongs_to :cash_dividend, dependent: :destroy
end
