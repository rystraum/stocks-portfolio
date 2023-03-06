class DLTableComponent < ViewComponent::Base
  attr_reader :title, :value
  def initialize(title, value = nil)
    @title = title
    @value = value.to_s
  end
end