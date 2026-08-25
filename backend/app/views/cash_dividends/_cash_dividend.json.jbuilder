# frozen_string_literal: true

json.extract! cash_dividend, :id, :company_id, :amount, :pay_date, :ex_date, :created_at, :updated_at
json.url cash_dividend_url(cash_dividend, format: :json)
