# frozen_string_literal: true

class PriceUpdate < ApplicationRecord
  belongs_to :company

  def to_formatted_s
    "#{price} @ #{datetime.to_formatted_s :long}"
  end
end
