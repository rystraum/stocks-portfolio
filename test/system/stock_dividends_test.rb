require "application_system_test_case"

class StockDividendsTest < ApplicationSystemTestCase
  setup do
    @stock_dividend = stock_dividends(:one)
  end

  test "visiting the index" do
    visit stock_dividends_url
    assert_selector "h1", text: "Stock Dividends"
  end

  test "creating a Stock dividend" do
    visit stock_dividends_url
    click_on "New Stock Dividend"

    fill_in "Amount", with: @stock_dividend.amount
    fill_in "Company", with: @stock_dividend.company_id
    fill_in "Ex date", with: @stock_dividend.ex_date
    fill_in "Pay date", with: @stock_dividend.pay_date
    click_on "Create Stock dividend"

    assert_text "Stock dividend was successfully created"
    click_on "Back"
  end

  test "updating a Stock dividend" do
    visit stock_dividends_url
    click_on "Edit", match: :first

    fill_in "Amount", with: @stock_dividend.amount
    fill_in "Company", with: @stock_dividend.company_id
    fill_in "Ex date", with: @stock_dividend.ex_date
    fill_in "Pay date", with: @stock_dividend.pay_date
    click_on "Update Stock dividend"

    assert_text "Stock dividend was successfully updated"
    click_on "Back"
  end

  test "destroying a Stock dividend" do
    visit stock_dividends_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Stock dividend was successfully destroyed"
  end
end
