# frozen_string_literal: true

class DLTableComponent < ViewComponent::Base
  attr_reader :title, :value

  def initialize(title, value = nil, &block)
    @title = title
    @value = normalize_value(block || -> { value }).to_s
  end

  private

  def normalize_value(callable)
    value = callable.call
    value.nil? ? 0 : value
  rescue TypeError, NoMethodError
    0
  end
end
