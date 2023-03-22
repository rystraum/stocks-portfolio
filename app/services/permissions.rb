class Permissions
  attr_reader :user
  def initialize(user)
    @user = user
  end

  def can?(action, target)
    return false if user.blank?
    return true if user.email == "rystraum@gmail.com"
    return false
  end
end