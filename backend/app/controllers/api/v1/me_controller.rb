# frozen_string_literal: true

class Api::V1::MeController < Api::V1::BaseController
  def index
    render json: { email: current_user.email }
  end
end
