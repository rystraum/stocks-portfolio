# frozen_string_literal: true

json.extract! stock_dividend, :id, :company_id, :amount, :pay_date, :ex_date, :created_at, :updated_at
json.url stock_dividend_url(stock_dividend, format: :json)
