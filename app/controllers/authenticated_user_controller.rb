# frozen_string_literal: true

class AuthenticatedUserController < ApplicationController
  before_action :authenticate_user!
  before_action :set_permissions
  def set_permissions
    @set_permissions ||= Permissions.new(current_user)
  end
end
