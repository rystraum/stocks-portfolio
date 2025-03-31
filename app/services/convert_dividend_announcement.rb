# frozen_string_literal: true

class ConvertDividendAnnouncement
  attr_accessor :dividend_announcement, :user, :net_wt

  def initialize(dividend_announcement, user)
    @dividend_announcement = dividend_announcement
    @user = user

    portfolio = UserPortfolioCompany.new(user, dividend_announcement.company)
    total_dividends = portfolio.total_shares * dividend_announcement.amount

    @net_wt = total_dividends * 0.9
  end

  def call
    if @dividend_announcement.payout_date > Date.today
      return [false, 'Dividend announcement pay date not in the future']
    end

    if existing_cash_dividend.present?
      create_converted(existing_cash_dividend)
      return [true, 'Successfully linked existing dividend']
    end

    cash_dividend = create_cash_dividend

    if cash_dividend.persisted?
      create_converted(cash_dividend)
      return [true, 'Successfully created new cash dividend']
    end

    return [false, 'Error saving cash dividend']
  end

  private

  def existing_cash_dividend
    return @existing_cash_dividend if @existing_cash_dividend

    # we need to do a range because of rounding differences
    net_wt_lb = net_wt - 0.01
    net_wt_ub = net_wt + 0.01

    @existing_cash_dividend = user.cash_dividends.where(
      company_id: dividend_announcement.company_id,
      ex_date: dividend_announcement.ex_date,
      amount: net_wt_lb..net_wt_ub,
    ).first

    @existing_cash_dividend
  end

  def create_converted(cash_dividend)
    ConvertedAnnouncement.create(
      dividend_announcement: @dividend_announcement,
      user: user,
      cash_dividend: cash_dividend,
    )
  end

  def create_cash_dividend
    user.cash_dividends.create(
      company_id: dividend_announcement.company_id,
      ex_date: dividend_announcement.ex_date,
      pay_date: dividend_announcement.pay_date,
      amount: net_wt,
    )
  end
end
