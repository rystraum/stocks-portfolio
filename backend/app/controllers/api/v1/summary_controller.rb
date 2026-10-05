# frozen_string_literal: true

class Api::V1::SummaryController < Api::V1::BaseController
  def index
    set = company_set
    companies = set.companies
    upcs = companies.map { |company| set.get_portfolio(company) }

    unrealized = upcs.sum { |upc| upc.total_shares.positive? ? upc.last_value - upc.total_costs : 0 }
    realized = companies.sum do |company|
      acts = ActivitiesCalculator.new(company.activities.where(user_id: current_user.id))
      acts.sold_shares.positive? ? acts.sell_gains - acts.cps_on_buy * acts.sold_shares : 0
    end

    invested_by_year = Activity.where(user_id: current_user.id, activity_type: "BUY")
                               .group_by { |a| a.date.year }
                               .transform_values { |acts| acts.sum { |a| a.total_price.to_f } }
    cumulative = 0.0
    capital_by_year = invested_by_year.keys.sort.map do |year|
      cumulative += invested_by_year[year]
      { year:, invested: round2(invested_by_year[year]), cumulative_cost: round2(cumulative) }
    end

    render json: {
      total_cost: round2(set.total_costs),
      current_value: round2(set.total_value),
      unrealized_pl: round2(unrealized),
      realized_pl: round2(realized),
      total_pl: round2(unrealized + realized),
      dividends: round2(set.total_dividends),
      value_plus_divs: round2(set.total_value + set.total_dividends),
      total_return_incl_divs: round2(set.total_value + set.total_dividends + realized - set.total_costs),
      currency: "PHP",
      as_of: Time.zone.now,
      capital_by_year:
    }
  end
end
