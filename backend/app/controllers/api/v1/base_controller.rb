# frozen_string_literal: true

class Api::V1::BaseController < AuthenticatedUserController
  private

  def company_set
    @company_set ||= CompanySet.new(UserPortfolio.new(current_user).company_ids, current_user)
  end

  def round2(value)
    return nil if value.nil?

    value.round(2)
  end

  def holding_payload(company)
    upc = company_set.get_portfolio(company)
    acts = ActivitiesCalculator.new(company.activities.where(user_id: current_user.id))
    shares = upc.total_shares
    realized = acts.sold_shares.positive? ? acts.sell_gains - acts.cps_on_buy * acts.sold_shares : nil

    {
      ticker: company.ticker,
      name: company.name,
      industry: company.industry,
      shares: shares,
      total_cost: round2(upc.total_costs),
      last_price: company.last_price,
      last_price_at: company.last_price_timestamp,
      target_buy: round2(company.target_buy_price),
      dividends: round2(upc.cash_dividends_total),
      realized_pl: round2(realized),
      active: !company.inactive && shares.positive?
    }
  end

  def dividend_months_for(year)
    dividends = CashDividend.where(user_id: current_user.id, pay_date: Date.new(year, 1, 1)..Date.new(year, 12, 31))
                             .includes(:company)
                             .order(:pay_date)
    months = Array.new(12) do |i|
      items = dividends.select { |d| d.pay_date.month == i + 1 }.each_with_object(Hash.new(0)) do |d, h|
        h[d.company.ticker] += d.amount.to_f
      end
      {
        total: round2(items.values.sum),
        items: items.map { |ticker, amount| { ticker:, amount: round2(amount) } }
      }
    end
    months
  end
end
