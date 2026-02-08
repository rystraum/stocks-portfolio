# frozen_string_literal: true

class DropdownMenuComponent < ViewComponent::Base
  def initialize(menu_item_name:, menu_id:, links:)
    @menu_item_name = menu_item_name
    @menu_id = menu_id
    @links = links
  end
end
