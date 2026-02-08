# frozen_string_literal: true

class UserPortfolio
  attr_accessor :user

  def initialize(user)
    @user = user
  end

  delegate :companies, to: :user

  def company_ids
    @company_ids ||= companies.ids
  end
end
