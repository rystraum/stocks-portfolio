json.extract! activity, :id, :company_id, :activity_type, :number_of_shares, :total_price, :created_at, :updated_at
json.url activity_url(activity, format: :json)
