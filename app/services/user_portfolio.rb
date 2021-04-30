class UserPortfolio
  attr_accessor :user

  def initialize(user)
    @user = user
  end

  def companies
    user.companies
  end
end