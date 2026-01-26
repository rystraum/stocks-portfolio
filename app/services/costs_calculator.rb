class CostsCalculator
  def initialize(activities)
    @activities = activities
  end

  def costs_as_of(year: -> { Date.today.year }.call, month: -> { Date.today.month }.call)
    buys = []
    sells = []
    cutoff_date = Date.new(year, month, 1).end_of_month

    @activities.each do |activity|
      next if activity.date > cutoff_date
      buys << activity if activity.activity_type == "BUY"
      sells << activity if activity.activity_type == "SELL"
    end

    buys.sum(&:total_price) - sells.sum(&:total_price)
  end
end