class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :cash_dividends
  has_many :stock_dividends
  has_many :activities
  has_many :companies, -> { distinct }, through: :activities
  has_many :converted_announcements
  has_many :crypto_activities

  def gravatar_hash
    Digest::MD5.hexdigest email.downcase
  end

  def company_dividends(company)
    return (stock_dividends.where(company: company) + cash_dividends_with_price(company)).sort_by(&:pay_date)
  end

  def cash_dividends_with_price(company)
    return cash_dividends.includes(:last_price_update).where(company: company)
  end

  def cash_sum_dividends(company)
    return cash_dividends.includes(:last_price_update).where(company: company).sum(:amount)
  end

  def company_activities(company)
    return activities.where(company: company)
  end

  def bought_shares(company)
    get_calculator(company).bought_shares
  end

  def sold_shares(company)
    get_calculator(company).sold_shares
  end

  def total_shares(company)
    get_calculator(company).ending_shares
  end

  def total_amount(company)
    get_calculator(company).ending_pnl
  end

  def cost_basis(company)
    get_calculator(company).buy_costs
  end

  def cps_on_buy(company)
    get_calculator(company).cps_on_buy
  end

  private

  def get_calculator(company)
    @calculator ||= {}
    @calculator[company.id] ||= ActivitiesCalculator.new(company_activities(company))
  end
end
