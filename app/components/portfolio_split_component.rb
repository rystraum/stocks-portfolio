# frozen_string_literal: true

class PortfolioSplitComponent < ViewComponent::Base
  def initialize(cash:, uitf:, stock:, crypto:)
    @cash = cash
    @uitf = uitf
    @stock = stock
    @crypto = crypto

    @total_spent = @cash.spent + @uitf.spent + @stock.spent + @crypto.spent
    @total_current_value = @cash.current_value + @uitf.current_value + @stock.current_value + @crypto.current_value
    @total_change = @total_current_value - @total_spent
  end
end