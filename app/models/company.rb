# frozen_string_literal: true

class Company < ApplicationRecord
  validates :ticker, uniqueness: true, presence: true
  has_many :activities
  has_many :stock_dividends
  has_many :cash_dividends
  has_many :price_updates

  scope :alphabetical, -> { order(:ticker) }
  scope :active, -> { where(inactive: false) }

  def to_s
    "#{ticker} [#{id}]"
  end

  def dividends
    (stock_dividends + cash_dividends).sort_by(&:pay_date)
  end

  def total_shares
    @total_shares ||= bought_shares - sold_shares + stock_dividend_shares
  end

  def total_costs
    return 0 if total_shares == 0

    actual_total_costs
  end

  def actual_total_costs
    @actual_total_costs ||= buy_costs - sell_gains
  end

  def cps
    total_costs / total_shares
  rescue ZeroDivisionError
    0
  end

  def last_price
    @last_price ||= price_updates.order('datetime desc').first&.price
  end

  def last_price_timestamp
    @last_price_timestamp ||= price_updates.order('datetime desc').first&.datetime&.to_datetime || DateTime.now
  end

  def last_value
    @last_value ||= total_shares * last_price
  end

  def profit_loss
    @profit_loss ||= last_value - actual_total_costs
  end

  def cash_dividends_total
    cash_dividends.pluck(:amount).sum
  end

  def cash_dividends_annual_dps
    cash_dividends_average_dps * cash_dividends_count_in_a_year
  end

  def history
    @history ||= (activities + stock_dividends + cash_dividends).sort_by do |thing|
      if thing.is_a?(Activity)
        thing.date
      else
        (thing.ex_date.blank? ? thing.pay_date : thing.ex_date)
      end
    end
  end

  def final_profit_loss
    cash_dividends_total + profit_loss
  end

  def profit_loss_percent
    profit_loss / actual_total_costs
  end

  def can_update_from_pse?
    !pse_company_id.blank? && !pse_security_id.blank?
  end

  def price_update_from_pse
    body = HTTParty.get("https://edge.pse.com.ph/companyPage/stockData.do?cmpy_id=#{pse_company_id.to_s}&security_id=#{pse_security_id.to_s}")
    document = Nokogiri::HTML.parse(body)

    # Expecting a structure something like:
    # <form name="form1" action="/companyPage/stockData.do">
    #   <input type="hidden" name="cmpy_id" value="57">
    #   <select name="security_id" onchange="document.form1.submit();">
    #     <option value="180" selected="">AC</option>
    #     <option value="651">APB2R</option>
    #     <option value="546">ACPA</option>
    #     <option value="523">ACPB1</option>
    #   </select>
    #   <span style="margin-left:1em;">As of Mar 30, 2021 12:50 PM</span>
    #   <span style="float:right; margin-left:1em;">
    #   </span>
    # </form>
    begin
      date_string = document.css("form[name=form1]").first.children[5].children.first.to_s
      datetime = DateTime.strptime("#{date_string.match(/As of (.*)/)[1]} +0800", "%h %d, %Y %H:%M %p %z")
    rescue NoMethodError => e
      binding.pry if Rails.env.development?
      raise "HTML does not match expected format: #{document.to_s}"
    rescue Date::Error => e
      binding.pry if Rails.env.development?
      raise "HTML does not match expected format: #{document.to_s}"
    end

    last_trade_label = document.css("table.view").last.children[3].children[1].to_s
    raise "HTML does not match expected format" if !last_trade_label.match? /Last Traded Price/

    last_trade_value = document.css("table.view").last.children[3].children[3].children.to_s.sub("\r\n", "").to_d

    price_update = price_updates.where(datetime: datetime).first_or_create do |update|
      update.price = last_trade_value.zero? ? last_price : last_trade_value
      update.notes = body
    end

    price_update
  end

  def fetch_history
    require 'net/http'
    require 'uri'

    uri = URI.parse('https://edge.pse.com.ph/common/DisclosureCht.ax')
    request = Net::HTTP::Post.new(uri)
    data = {
      'cmpy_id': pse_company_id.to_s,
      'security_id': pse_security_id.to_s,
      'startDate': 30.days.ago.strftime('%m-%d-%Y'),
      'endDate': Date.today.strftime('%m-%d-%Y')
    }.to_json.unpack('C*')

    request['Connection'] = 'keep-alive'
    request['Pragma'] = 'no-cache'
    request['Cache-Control'] = 'no-cache'
    request['Dnt'] = '1'
    request['X-Requested-With'] = 'XMLHttpRequest'
    request['User-Agent'] = 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.88 Safari/537.36'
    request['Accept'] = 'Accept: application/json, text/javascript, */*; q=0.01'
    request['Origin'] = 'https://edge.pse.com.ph'
    request['Content-Type'] = 'application/json'
    request['Sec-Fetch-Site'] = 'same-origin'
    request['Sec-Fetch-Mode'] = 'cors'
    request['Sec-Fetch-Dest'] = 'empty'
    request['Referer'] = "https://edge.pse.com.ph/companyPage/stockData.do?cmpy_id=#{pse_company_id}&security=#{pse_security_id}"
    request['Accept-Language'] = 'en-US,en;q=0.9'
    request['Cookie'] = 'Cookie: JSESSIONID=uhHyB6YqPkdIEjpEWZ9hVwrH.server-ep; BIGipServerPOOL_EDGE=1427584378.20480.0000; access=approve'
    request.content_type = 'application/octet-stream'
    request.set_form_data(data)

    req_options = {
      use_ssl: uri.scheme == 'https'
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end

    puts response.code
    response.body
  end

  protected

  def cash_dividends_average_dps
    return 0 if cash_dividends.length.zero?

    dividends = cash_dividends.collect(&:dividend_per_share).collect(&:to_f).reject(&:zero?)
    @cash_dividends_average_dps ||= (dividends.sum / dividends.length)
  end

  def cash_dividends_count_in_a_year
    return 0 if cash_dividends.length.zero?

    count = cash_dividends.collect(&:pay_date).group_by(&:year).collect { |_year, arr| arr.count }
    @cash_dividends_count_in_a_year ||= (count.sum.to_f / count.length).round(0)
  end

  def stock_dividend_shares
    stock_dividends.pluck(:amount).sum
  end

  def bought_shares
    activities_calculator.bought_shares
  end

  def sold_shares
    activities_calculator.sold_shares
  end

  def buy_costs
    activities_calculator.buy_costs
  end

  def sell_gains
    activities_calculator.sell_gains
  end

  def activities_calculator
    @activities_calculator ||= ActivitiesCalculator.new(activities)
  end
end
