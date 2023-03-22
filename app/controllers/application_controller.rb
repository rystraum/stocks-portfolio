# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :set_permissions
  def set_permissions
    @permissions ||= Permissions.new(current_user)
  end
end
