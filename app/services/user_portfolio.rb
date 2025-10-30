class UserPortfolio
  attr_accessor :user

  def initialize(user)
    @user = user
  end

  def companies
    user.companies
  end

  def company_ids
    @company_ids ||= companies.ids
  end
end