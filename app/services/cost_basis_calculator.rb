# frozen_string_literal: true

class CostBasisCalculator
  attr_reader :crypto, :fiat, :rate

  def initialize(crypto_activities)
    @crypto_activities = crypto_activities.sort_by(&:activity_date)
    @crypto = 0.0
    @fiat = 0.0
    @rate = 0.0
  end

  def cost_basis!
    @crypto_activities.each do |activity|
      # puts "Activity: #{activity}"
      activity.buy? ? bought(activity) : sold(activity)
      # puts "Crypto: #{@crypto}, Fiat: #{@fiat}, Rate: #{@rate}"
    end
  end

  private

  def bought(activity)
    # @crypto += activity.crypto_amount
    @crypto += (activity.crypto_amount - activity.fee_crypto)
    @fiat += activity.fiat_amount
    @rate = @fiat / @crypto
  end

  def sold(activity)
    fiat_pre_selling = @fiat
    crypto_pre_selling = @crypto

    @crypto -= activity.crypto_amount
    sold_proportion = activity.crypto_amount / crypto_pre_selling
    fiat_equivalent_sold = fiat_pre_selling * sold_proportion

    @fiat = fiat_pre_selling - fiat_equivalent_sold
    # there's a weird case here wherein rate might be 0.
    # this would happen if the first activity is a sell, or you're selling more than what you have
  end
end
