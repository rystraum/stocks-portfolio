class UserPortfolio
  def initialize(user)
    @user = user
  end

  def companies
    Company.all
  end
end