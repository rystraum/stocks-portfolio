# frozen_string_literal: true
require 'forwardable'

class CashDividendSet
  extend Forwardable
  attr_accessor :dividends
  attr_reader :dividends, :years, :amounts

  def_delegators :@dividends, :each

  def initialize(dividends)
    @dividends = dividends
    @years = {}
    @amounts = {}

    dividends.each do |cash_dividend|
      @years[cash_dividend.pay_date.year] ||= {}
      @years[cash_dividend.pay_date.year][cash_dividend.pay_date.month] ||= Set.new
      @years[cash_dividend.pay_date.year][cash_dividend.pay_date.month] << cash_dividend.company.ticker
      @amounts[cash_dividend.pay_date.year] ||= {}
      @amounts[cash_dividend.pay_date.year][cash_dividend.pay_date.month] ||= 0
      @amounts[cash_dividend.pay_date.year][cash_dividend.pay_date.month] += cash_dividend.amount
    end
  end

  
end