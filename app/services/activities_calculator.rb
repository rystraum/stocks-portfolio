# frozen_string_literal: true

class ActivitiesCalculator
  attr_accessor :activities

  def initialize(activities)
    @activities = activities
  end

  def ending_shares
    bought_shares - sold_shares
  end

  def ending_pnl
    sell_gains - buy_costs
  end

  def bought_shares
    @bought_shares ||= buy.collect(&:number_of_shares).sum
  end

  def sold_shares
    @sold_shares ||= sell.collect(&:number_of_shares).sum
  end

  def buy_costs
    @buy_costs ||= buy.collect(&:total_price).sum
  end

  def sell_gains
    @sell_gains ||= sell.collect(&:total_price).sum
  end

  def cps_on_buy
    return 0 if bought_shares.zero?

    buy_costs / bought_shares
  end

  protected

  def buy
    @buy ||= activities.select { |a| a.activity_type == "BUY" }
  end

  def sell
    @sell ||= activities.select { |a| a.activity_type == "SELL" }
  end
end
