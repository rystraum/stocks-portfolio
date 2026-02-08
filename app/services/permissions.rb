# frozen_string_literal: true

class Permissions
  attr_reader :user

  def initialize(user)
    @user = user
  end

  def can?(_action, target)
    return false if user.blank?
    return resolve_activities(target) if target.is_a?(Activity)
    return true if user.email == "rystraum@gmail.com"

    return false
  end

  private

  def resolve_activities(activity)
    return true if activity.user_id == user.id

    return false
  end
end
