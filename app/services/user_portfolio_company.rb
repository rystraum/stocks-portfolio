class UserPortfolioCompany
  attr_reader :user, :company
  def initialize(user, company)
    @user = user
    @company = company
  end

  def history
    @history ||= (activities + stock_dividends + cash_dividends).sort_by do |thing|
      if thing.is_a?(Activity)
        thing.date
      else
        (thing.ex_date.blank? ? thing.pay_date : thing.ex_date)
      end
    end
  end

  def dividends
    (stock_dividends + cash_dividends).sort_by(&:pay_date)
  end

  def total_costs
    return 0 if total_shares == 0

    actual_total_costs
  end

  def actual_total_costs
    @actual_total_costs ||= buy_costs - sell_gains
  end

  def last_value
    @last_value ||= total_shares * last_price
  end

  def cash_dividends_total
    cash_dividends.pluck(:amount).sum
  end

  def total_shares
    @total_shares ||= bought_shares - sold_shares + stock_dividend_shares || 0
  end

  def cps
    return 0 if total_costs.zero?
    total_costs / total_shares
  end

  def profit_loss
    @profit_loss ||= last_value - actual_total_costs
  end

  def final_profit_loss
    cash_dividends_total + profit_loss
  end

  def profit_loss_percent
    return 0.0 if actual_total_costs.zero?

    profit_loss / actual_total_costs
  end

  private

  def last_price
    @last_price ||= company.last_price
  end
  
  def activities
    @activities ||= company.activities.where(user_id: user.id)
  end

  def stock_dividends
    @stock_dividends ||= company.stock_dividends.where(user_id: user.id)
  end

  def cash_dividends
    @cash_dividends ||= company.cash_dividends.where(user_id: user.id)
  end

  def activities_calculator
    @activities_calculator ||= ActivitiesCalculator.new(activities)
  end

  def bought_shares
    activities_calculator.bought_shares
  end

  def sold_shares
    activities_calculator.sold_shares
  end

  def stock_dividend_shares
    stock_dividends.pluck(:amount).sum
  end

  def buy_costs
    activities_calculator.buy_costs
  end

  def sell_gains
    activities_calculator.sell_gains
  end
end