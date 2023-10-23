require 'test_helper'

class CostsCalculatorTest < ActiveSupport::TestCase
  test "#costs_as_of happy path" do
    activities = [
      OpenStruct.new(date: Date.new(2023, 1, 1), activity_type: "BUY", total_price: 1000.00, company_id: 1),
      OpenStruct.new(date: Date.new(2023, 1, 2), activity_type: "SELL", total_price: 1000.00, company_id: 1),
      OpenStruct.new(date: Date.new(2023, 2, 1), activity_type: "BUY", total_price: 1000.00, company_id: 1),
      OpenStruct.new(date: Date.new(2023, 3, 1), activity_type: "BUY", total_price: 1000.00, company_id: 1),
      OpenStruct.new(date: Date.new(2023, 4, 1), activity_type: "BUY", total_price: 1000.00, company_id: 1),
      OpenStruct.new(date: Date.new(2023, 5, 1), activity_type: "BUY", total_price: 1000.00, company_id: 1),
      OpenStruct.new(date: Date.new(2023, 6, 1), activity_type: "BUY", total_price: 1000.00, company_id: 1),
      OpenStruct.new(date: Date.new(2023, 7, 1), activity_type: "BUY", total_price: 1000.00, company_id: 1),
      OpenStruct.new(date: Date.new(2023, 8, 1), activity_type: "BUY", total_price: 1000.00, company_id: 1),
      OpenStruct.new(date: Date.new(2023, 9, 1), activity_type: "BUY", total_price: 1000.00, company_id: 1),
      OpenStruct.new(date: Date.new(2023, 10, 1), activity_type: "BUY", total_price: 1000.00, company_id: 1),
      OpenStruct.new(date: Date.new(2023, 11, 1), activity_type: "BUY", total_price: 1000.00, company_id: 1),
      OpenStruct.new(date: Date.new(2023, 12, 1), activity_type: "BUY", total_price: 1000.00, company_id: 1)
    ]
    cc = CostsCalculator.new(activities)
    assert_equal 11000.00, cc.costs_as_of(year: 2023, month: 12)
    assert_equal 5000.00, cc.costs_as_of(year: 2023, month: 6)
  end
end
