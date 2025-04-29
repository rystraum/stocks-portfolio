# frozen_string_literal: true
require 'forwardable'

class CashDividendSet
  extend Forwardable
  attr_accessor :dividends
  attr_reader :dividends, :years, :amounts, :breakdown, :sums

  def_delegators :@dividends, :each

  def initialize(dividends)
    @dividends = dividends
    @years = {}
    @amounts = {}
    @breakdown = {}
    @sums = {}

    dividends.each do |cash_dividend|
      year = cash_dividend.pay_date.year.to_s
      month = cash_dividend.pay_date.month.to_s
      ticker = cash_dividend.company.ticker
      amount = cash_dividend.amount

      @years[year] ||= {}
      @years[year][month] ||= Set.new
      @years[year][month] << ticker

      @breakdown[year] ||= {}
      @breakdown[year][month] ||= {}
      @breakdown[year][month][ticker] ||= 0
      @breakdown[year][month][ticker] += amount

      @amounts[year] ||= {}
      @amounts[year][month] ||= 0
      @amounts[year][month] += amount

      @sums[year] ||= 0
      @sums[year] += amount
    end
  end
end