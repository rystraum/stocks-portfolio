# frozen_string_literal: true

require "test_helper"

class PSETest < ActiveSupport::TestCase
  test "price_update! raises when company cannot update" do
    company = Company.create!(ticker: "NOUPD")

    assert_raises(RuntimeError, "Company can't update from PSE") do
      PSE.new(company).price_update!
    end
  end

  test "price_update! creates price update from scraped html" do
    company = Company.create!(ticker: "AC", pse_company_id: "57", pse_security_id: "180")
    response = OpenStruct.new(body: price_update_html)

    stub_httparty(:get, response) do
      price_update = PSE.new(company).price_update!

      assert_equal 1234.0, price_update.price.to_f
      assert_equal DateTime.new(2021, 3, 30, 12, 50, 0, "+08:00"), price_update.datetime
      assert_equal 1, company.price_updates.count
    end
  end

  test "price_update! updates existing price update when forced" do
    company = Company.create!(ticker: "ACFORCE", pse_company_id: "57", pse_security_id: "180")
    datetime = DateTime.new(2021, 3, 30, 12, 50, 0, "+08:00")
    company.price_updates.create!(price: 100.0, datetime: datetime)
    response = OpenStruct.new(body: price_update_html)

    stub_httparty(:get, response) do
      price_update = PSE.new(company, force: true).price_update!

      assert_equal 1234.0, price_update.price.to_f
    end
  end

  test "dividend_announcements! creates cash announcements and skips stock" do
    company = Company.create!(ticker: "COMMON", pse_company_id: "57", pse_security_id: "180")
    response = OpenStruct.new(body: dividend_announcement_html("COMMON", "CASH-1"))

    stub_httparty(:post, response) do
      created = PSE.new(company).dividend_announcements!

      assert_equal 1, created
      assert_equal 1, DividendAnnouncement.where(company: company).count
    end
  end

  test "dividend_announcements! matches preferred share class" do
    company = Company.create!(ticker: "PREF", industry: "Preferred", pse_company_id: "57", pse_security_id: "180")
    response = OpenStruct.new(body: dividend_announcement_html("PREF", "CASH-2"))

    stub_httparty(:post, response) do
      created = PSE.new(company).dividend_announcements!

      assert_equal 1, created
      assert_equal 1, DividendAnnouncement.where(company: company).count
    end
  end

  test "fetch_history returns response body" do
    company = Company.create!(ticker: "HIST", pse_company_id: "57", pse_security_id: "180")
    response = OpenStruct.new(code: "200", body: "history")
    http = Object.new
    http.define_singleton_method(:request) { |_req| response }

    stub_net_http_start(http) do
      assert_equal "history", PSE.new(company).fetch_history
    end
  end

  private

  def price_update_html
    <<~HTML
      <form name="form1">
        <input />
        <select></select>
        <span style="margin-left:1em;">As of Mar 30, 2021 12:50 PM</span>
        <span style="float:right; margin-left:1em;"></span>
      </form>
      <table class="view">
        <tr><td>Ignore</td></tr>
        <tr>
          <td>Last Traded Price</td>
          <td>1,234</td>
        </tr>
      </table>
    HTML
  end

  def dividend_announcement_html(share_class, circular_number)
    <<~HTML
      <table>
        <tbody>
          <tr>
            <td>#{share_class}</td>
            <td>Cash</td>
            <td>P1.25</td>
            <td>Apr 07, 2025</td>
            <td>Apr 08, 2025</td>
            <td>Apr 23, 2025</td>
            <td><a>#{circular_number}</a></td>
          </tr>
          <tr>
            <td>#{share_class}</td>
            <td>Stock</td>
            <td>P1.25</td>
            <td>Apr 07, 2025</td>
            <td>Apr 08, 2025</td>
            <td>Apr 23, 2025</td>
            <td><a>SKIP-#{circular_number}</a></td>
          </tr>
        </tbody>
      </table>
    HTML
  end

  def stub_httparty(method_name, response)
    original = HTTParty.method(method_name)
    HTTParty.define_singleton_method(method_name) { |_url, *_args| response }
    yield
  ensure
    HTTParty.define_singleton_method(method_name, original.to_proc)
  end

  def stub_net_http_start(http)
    original = Net::HTTP.method(:start)
    Net::HTTP.define_singleton_method(:start) { |*_args, &block| block.call(http) }
    yield
  ensure
    Net::HTTP.define_singleton_method(:start, original.to_proc)
  end
end
