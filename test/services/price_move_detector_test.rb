# frozen_string_literal: true

require "test_helper"

class PriceMoveDetectorTest < ActiveSupport::TestCase
  test "key_dates computes day over day pct change and filters by min_pct" do
    company = Company.create!(ticker: "DETECT")
    create_price(company, 100.0, 5.days.ago)
    create_price(company, 105.0, 4.days.ago) # +5.00%
    create_price(company, 101.0, 3.days.ago) # -3.81%
    create_price(company, 101.5, 2.days.ago) # +0.50%, below min_pct

    moves = PriceMoveDetector.new(company, range_days: 30).key_dates

    assert_equal([4.days.ago.to_date, 3.days.ago.to_date], moves.map { _1[:date] })
    assert_in_delta 5.0, moves.first[:pct_change].to_f
    assert_equal 105.0, moves.first[:close_price].to_f
    assert_in_delta(-3.81, moves.second[:pct_change].to_f, 0.01)
  end

  test "key_dates keeps the last row per calendar date" do
    company = Company.create!(ticker: "DEDUP")
    create_price(company, 999.0, 5.days.ago.change(hour: 9))  # earlier scrape, superseded
    create_price(company, 100.0, 5.days.ago.change(hour: 15)) # later row for the same date wins
    create_price(company, 105.0, 4.days.ago)

    moves = PriceMoveDetector.new(company, range_days: 30).key_dates

    assert_equal 1, moves.length
    assert_equal 4.days.ago.to_date, moves.first[:date]
    assert_in_delta 5.0, moves.first[:pct_change].to_f
  end

  test "key_dates respects the limit ordered by absolute pct change" do
    company = Company.create!(ticker: "LIMIT")
    prices = [100.0, 105.0, 99.75, 104.74, 99.50, 104.48, 99.26]
    prices.each_with_index do |price, index|
      create_price(company, price, (prices.length - index).days.ago)
    end

    moves = PriceMoveDetector.new(company, range_days: 30).key_dates(limit: 5)

    assert_equal 5, moves.length
    assert(moves.all? { _1[:pct_change].abs >= 3.0 })
  end

  test "key_dates returns empty when there are no moves above min_pct" do
    company = Company.create!(ticker: "FLAT")
    create_price(company, 100.0, 2.days.ago)
    create_price(company, 100.5, 1.day.ago)

    assert_empty PriceMoveDetector.new(company, range_days: 30).key_dates
  end

  private

  def create_price(company, price, datetime)
    company.price_updates.create!(price: price, datetime: datetime)
  end
end
