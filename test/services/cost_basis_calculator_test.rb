# frozen_string_literal: true

require 'test_helper'

class CostBasisCalculatorTest < ActiveSupport::TestCase
  test "cost_basis happy path 1" do
    # calculator = CostBasisCalculator.new(CryptoActivity.where(user: User.last, crypto_currency_id: CryptoCurrency.find_by(ticker: "ETHUSDT")))

    activities = [
      OpenStruct.new(buy?: true,  activity_date: Date.new(2023,  1, 1), crypto_amount: 0.026682, fiat_amount: 103.56, fee_crypto: 0.000034023),
      # OpenStruct.new(buy?: false, activity_date: Date.new(2023,  1, 2), crypto_amount: 0.022647, fiat_amount: 108.17),
      # OpenStruct.new(buy?: true,  activity_date: Date.new(2023,  1, 3), crypto_amount: 0.024475, fiat_amount: 108.01, fee_crypto: 0.0000367125),
      # OpenStruct.new(buy?: true,  activity_date: Date.new(2023,  1, 4), crypto_amount: 0.015308, fiat_amount: 69.80, fee_crypto: 0.000022962),
      # OpenStruct.new(buy?: true,  activity_date: Date.new(2023,  1, 5), crypto_amount: 0.015723, fiat_amount: 69.66, fee_crypto: 0.000015723),
      # OpenStruct.new(buy?: true,  activity_date: Date.new(2023,  1, 6), crypto_amount: 0.033502, fiat_amount: 140.44, fee_crypto: 0.000050253),
    ]

    calculator = CostBasisCalculator.new(activities)
    calculator.cost_basis!

    assert_in_delta 0.0266479770, calculator.crypto, 0.00000001
    assert_in_delta 103.56, calculator.fiat, 0.01
    assert_in_delta 3886.223708, calculator.rate, 0.00001

    # assert_equal 0.0928833265, calculator.crypto
    # assert_in_delta 403.45, calculator.fiat, 0.01
  end

  test "cost_basis happy path 2" do
    # calculator = CostBasisCalculator.new(CryptoActivity.where(user: User.last, crypto_currency_id: CryptoCurrency.find_by(ticker: "ETHUSDT")))

    activities = [
      OpenStruct.new(buy?: true,  activity_date: Date.new(2023,  1, 1), crypto_amount: 0.026682, fiat_amount: 103.56, fee_crypto: 0.000034023),
      OpenStruct.new(buy?: false, activity_date: Date.new(2023,  1, 2), crypto_amount: 0.022647, fiat_amount: 108.00),
      # OpenStruct.new(buy?: true,  activity_date: Date.new(2023,  1, 3), crypto_amount: 0.024475, fiat_amount: 108.01, fee_crypto: 0.0000367125),
      # OpenStruct.new(buy?: true,  activity_date: Date.new(2023,  1, 4), crypto_amount: 0.015308, fiat_amount: 69.80, fee_crypto: 0.000022962),
      # OpenStruct.new(buy?: true,  activity_date: Date.new(2023,  1, 5), crypto_amount: 0.015723, fiat_amount: 69.66, fee_crypto: 0.000015723),
      # OpenStruct.new(buy?: true,  activity_date: Date.new(2023,  1, 6), crypto_amount: 0.033502, fiat_amount: 140.44, fee_crypto: 0.000050253),
    ]

    calculator = CostBasisCalculator.new(activities)
    calculator.cost_basis!

    assert_in_delta 0.00400097, calculator.crypto, 0.00000001
    assert_in_delta 15.55, calculator.fiat, 0.01
    assert_in_delta 3886.223708, calculator.rate, 0.00001
  end

  test "cost_basis happy path 3" do
    # calculator = CostBasisCalculator.new(CryptoActivity.where(user: User.last, crypto_currency_id: CryptoCurrency.find_by(ticker: "ETHUSDT")))

    activities = [
      OpenStruct.new(buy?: true,  activity_date: Date.new(2023,  1, 1), crypto_amount: 0.026682, fiat_amount: 103.56, fee_crypto: 0.000034023),
      OpenStruct.new(buy?: false, activity_date: Date.new(2023,  1, 2), crypto_amount: 0.022647, fiat_amount: 108.17),
      OpenStruct.new(buy?: true,  activity_date: Date.new(2023,  1, 3), crypto_amount: 0.024475, fiat_amount: 108.01, fee_crypto: 0.0000367125),
      # OpenStruct.new(buy?: true,  activity_date: Date.new(2023,  1, 4), crypto_amount: 0.015308, fiat_amount: 69.80, fee_crypto: 0.000022962),
      # OpenStruct.new(buy?: true,  activity_date: Date.new(2023,  1, 5), crypto_amount: 0.015723, fiat_amount: 69.66, fee_crypto: 0.000015723),
      # OpenStruct.new(buy?: true,  activity_date: Date.new(2023,  1, 6), crypto_amount: 0.033502, fiat_amount: 140.44, fee_crypto: 0.000050253),
    ]

    calculator = CostBasisCalculator.new(activities)
    calculator.cost_basis!

    assert_in_delta 0.0284392575, calculator.crypto, 0.00000001
    assert_in_delta 123.56, calculator.fiat, 0.01
    assert_in_delta 4344.651447, calculator.rate, 0.00001
  end

  test "cost_basis happy path 4" do
    # calculator = CostBasisCalculator.new(CryptoActivity.where(user: User.last, crypto_currency_id: CryptoCurrency.find_by(ticker: "ETHUSDT")))

    activities = [
      OpenStruct.new(buy?: true,  activity_date: Date.new(2023,  1, 1), crypto_amount: 0.026682, fiat_amount: 103.56, fee_crypto: 0.000034023),
      OpenStruct.new(buy?: false, activity_date: Date.new(2023,  1, 2), crypto_amount: 0.022647, fiat_amount: 108.17),
      OpenStruct.new(buy?: true,  activity_date: Date.new(2023,  1, 3), crypto_amount: 0.024475, fiat_amount: 108.01, fee_crypto: 0.0000367125),
      OpenStruct.new(buy?: true,  activity_date: Date.new(2023,  1, 4), crypto_amount: 0.015308, fiat_amount: 69.80, fee_crypto: 0.000022962),
      OpenStruct.new(buy?: true,  activity_date: Date.new(2023,  1, 5), crypto_amount: 0.015723, fiat_amount: 69.66, fee_crypto: 0.000015723),
      OpenStruct.new(buy?: true,  activity_date: Date.new(2023,  1, 6), crypto_amount: 0.033502, fiat_amount: 140.44, fee_crypto: 0.000050253),
    ]

    calculator = CostBasisCalculator.new(activities)
    calculator.cost_basis!

    assert_in_delta 0.0928833265, calculator.crypto, 0.00000001
    assert_in_delta 403.46, calculator.fiat, 0.01
    assert_in_delta 4343.714926, calculator.rate, 0.00001
  end
end
