# frozen_string_literal: true

class PortfolioItem
  attr_reader :spent, :current_value
  def initialize(spent:, current_value:)
    @spent = spent
    @current_value = current_value
  end

  def change
    current_value - spent
  end
end
