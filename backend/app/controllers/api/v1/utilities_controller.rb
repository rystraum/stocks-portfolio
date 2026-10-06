# frozen_string_literal: true

class Api::V1::UtilitiesController < Api::V1::BaseController
  def update_prices
    UserPortfolio.new(current_user).companies.each_with_index do |company, index|
      next unless company.can_update_from_pse?

      PriceUpdateJob.set(wait: 2.seconds * index).perform_later(company)
    rescue RuntimeError
      nil
    end
    render json: { ok: true, queued: true }
  end

  def update_from_pse
    company = find_company!
    if company.nil?
      return render json: { ok: false, error: "No such ticker" }, status: :not_found
    end

    price_update = PSE.new(company).price_update!
    if price_update.persisted?
      render json: { ok: true, last_price: company.reload.last_price&.to_f }
    else
      render json: { ok: false, error: "Price update failed" }, status: :unprocessable_entity
    end
  end

  def backfill
    company = find_company!
    if company.nil?
      return render json: { ok: false, error: "No such ticker" }, status: :not_found
    end

    created = PSE.new(company).backfill_history!(1.year.ago.to_date)
    render json: { ok: true, created: created.to_i }
  rescue StandardError => e
    render json: { ok: false, error: e.message }, status: :unprocessable_entity
  end

  private

  def find_company!
    Company.where("UPPER(ticker) = ?", params[:ticker].to_s.upcase).first
  end
end
