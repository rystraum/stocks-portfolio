# frozen_string_literal: true

json.extract! price_update, :id, :company_id, :datetime, :price, :open, :high, :low, :created_at, :updated_at
json.url price_update_url(price_update, format: :json)
