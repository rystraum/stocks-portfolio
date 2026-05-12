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
      assert_equal 1200.0, price_update.open.to_f
      assert_equal 1250.0, price_update.high.to_f
      assert_equal 1190.0, price_update.low.to_f
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

  test "fetch_history returns parsed chart data" do
    company = Company.create!(ticker: "HIST", pse_company_id: "57", pse_security_id: "180")
    response = OpenStruct.new(code: "200", body: '{"chartData":[{"OPEN":100.0,"HIGH":110.0,"LOW":95.0,"CLOSE":105.0,"CHART_DATE":"May 01, 2021 00:00:00"}]}')
    http = Object.new
    http.define_singleton_method(:request) { |_req| response }

    stub_net_http_start(http) do
      history = PSE.new(company).fetch_history
      assert_equal 1, history.length
      assert_equal 100.0, history.first["OPEN"]
      assert_equal 110.0, history.first["HIGH"]
    end
  end

  test "extract_ohlc_from_html returns open high low from cached html" do
    values = PSE.extract_ohlc_from_html(price_update_html)

    assert_equal 1200.0, values[:open].to_f
    assert_equal 1250.0, values[:high].to_f
    assert_equal 1190.0, values[:low].to_f
  end

  test "extract_ohlc_from_html returns nil for invalid html" do
    assert_nil PSE.extract_ohlc_from_html("<html><body>no data</body></html>")
  end

  test "price_update! stores response body in notes" do
    company = Company.create!(ticker: "ACNOTES", pse_company_id: "57", pse_security_id: "180")
    response = OpenStruct.new(body: price_update_html)

    stub_httparty(:get, response) do
      price_update = PSE.new(company).price_update!

      assert price_update.notes.present?
      assert_includes price_update.notes, "Last Traded Price"
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
        <colgroup>
          <col width="17%"/>
          <col width="28%"/>
          <col width="31%"/>
          <col width="24%"/>
        </colgroup>
        <tr>
          <th>Status</th>
          <td>Open</td>
          <th>Market Capitalization</th>
          <td style="text-align:right;padding-right:1.5em;">100</td>
        </tr>
      </table>
      <table class="view">
        <colgroup>
          <col width="17%"/>
          <col width="18%"/>
          <col width="15%"/>
          <col width="13%"/>
          <col width="19%"/>
          <col width="18%"/>
        </colgroup>
        <tr>
          <th>Last Traded Price</th>
          <td style="text-align:right;padding-right:1.2em;">1,234</td>
          <th>Open</th>
          <td style="text-align:right;padding-right:1.2em;">1,200</td>
          <th>Previous Close and Date</th>
          <td style="text-align:right;padding-right:1.2em;">1,100 (Mar 29, 2021)</td>
        </tr>
        <tr>
          <th>Change(% Change)</th>
          <td style="text-align:right;padding-right:1.2em;">up 10 (1%)</td>
          <th>High</th>
          <td style="text-align:right;padding-right:1.2em;">1,250</td>
          <th>P/E Ratio</th>
          <td style="text-align:right;padding-right:1.2em;">15</td>
        </tr>
        <tr>
          <th>Value</th>
          <td style="text-align:right;padding-right:1.2em;">1000000</td>
          <th>Low</th>
          <td style="text-align:right;padding-right:1.2em;">1,190</td>
          <th>Sector P/E Ratio</th>
          <td style="text-align:right;padding-right:1.2em;">12</td>
        </tr>
        <tr>
          <th>Volume</th>
          <td style="text-align:right;padding-right:1.2em;">500</td>
          <th>Average Price</th>
          <td style="text-align:right;padding-right:1.2em;">1220</td>
          <th>Book Value</th>
          <td style="text-align:right;padding-right:1.2em;">100</td>
        </tr>
        <tr>
          <th>52-Week High</th>
          <td style="text-align:right;padding-right:1.2em;">2000</td>
          <th>52-Week Low</th>
          <td style="text-align:right;padding-right:1.2em;">500</td>
          <th>P/BV Ratio</th>
          <td style="text-align:right;padding-right:1.2em;">2</td>
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
