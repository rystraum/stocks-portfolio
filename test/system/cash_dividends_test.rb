require "application_system_test_case"

class CashDividendsTest < ApplicationSystemTestCase
  setup do
    @cash_dividend = cash_dividends(:one)
  end

  test "visiting the index" do
    visit cash_dividends_url
    assert_selector "h1", text: "Cash Dividends"
  end

  test "creating a Cash dividend" do
    visit cash_dividends_url
    click_on "New Cash Dividend"

    fill_in "Amount", with: @cash_dividend.amount
    fill_in "Company", with: @cash_dividend.company_id
    fill_in "Ex date", with: @cash_dividend.ex_date
    fill_in "Pay date", with: @cash_dividend.pay_date
    click_on "Create Cash dividend"

    assert_text "Cash dividend was successfully created"
    click_on "Back"
  end

  test "updating a Cash dividend" do
    visit cash_dividends_url
    click_on "Edit", match: :first

    fill_in "Amount", with: @cash_dividend.amount
    fill_in "Company", with: @cash_dividend.company_id
    fill_in "Ex date", with: @cash_dividend.ex_date
    fill_in "Pay date", with: @cash_dividend.pay_date
    click_on "Update Cash dividend"

    assert_text "Cash dividend was successfully updated"
    click_on "Back"
  end

  test "destroying a Cash dividend" do
    visit cash_dividends_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Cash dividend was successfully destroyed"
  end
end
