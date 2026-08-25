# frozen_string_literal: true

module Admin
  class AiCallsController < BaseController
    def index
      @ai_calls = AiCall.latest_first.limit(200)
    end

    def show
      @ai_call = AiCall.find(params[:id])
    end
  end
end
