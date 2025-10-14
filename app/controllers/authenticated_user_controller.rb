# frozen_string_literal: true

class AuthenticatedUserController < ApplicationController
  before_action :authenticate_user!
  before_action :set_permissions
  def set_permissions
    @permissions ||= Permissions.new(current_user)
  end
end
