class PSE
  attr_accessor :company
  def initialize(company)
    @company = company
  end

  def price_update!
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

    final_price = last_trade_value.zero? || last_trade_value.blank? ? company.last_price : last_trade_value
    
    return company.price_updates.order("created_at desc").first if final_price.blank?

    price_update = company.price_updates.where(datetime: datetime).first_or_create do |update|
      update.price = final_price
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

  private

  def pse_company_id
    company.pse_company_id
  end

  def pse_security_id
    company.pse_security_id
  end
end