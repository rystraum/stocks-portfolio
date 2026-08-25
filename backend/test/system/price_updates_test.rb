# frozen_string_literal: true

require "application_system_test_case"

class PriceUpdatesTest < ApplicationSystemTestCase
  setup do
    @price_update = price_updates(:one)
  end

  test "visiting the index" do
    visit price_updates_url
    assert_selector "h1", text: "Price Updates"
  end

  test "creating a Price update" do
    visit price_updates_url
    click_on "New Price Update"

    fill_in "Company", with: @price_update.company_id
    fill_in "Datetime", with: @price_update.datetime
    fill_in "Price", with: @price_update.price
    click_on "Create Price update"

    assert_text "Price update was successfully created"
    click_on "Back"
  end

  test "updating a Price update" do
    visit price_updates_url
    click_on "Edit", match: :first

    fill_in "Company", with: @price_update.company_id
    fill_in "Datetime", with: @price_update.datetime
    fill_in "Price", with: @price_update.price
    click_on "Update Price update"

    assert_text "Price update was successfully updated"
    click_on "Back"
  end

  test "destroying a Price update" do
    visit price_updates_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Price update was successfully destroyed"
  end
end
