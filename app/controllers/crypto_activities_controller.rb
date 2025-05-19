class CryptoActivitiesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_crypto_activity, only: [:show, :edit, :update, :destroy]

  def index
    @crypto_activities = current_user.crypto_activities.includes(:crypto_currency).order(activity_date: :desc)
  end

  def new
    @crypto_activity = current_user.crypto_activities.build(activity_date: Date.today)
  end

  def create
    @crypto_activity = current_user.crypto_activities.build(crypto_activity_params)
    if @crypto_activity.save
      redirect_to crypto_activities_path, notice: 'Crypto activity was successfully recorded.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @crypto_activity.update(crypto_activity_params)
      redirect_to crypto_activities_path, notice: 'Crypto activity was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @crypto_activity.destroy
    redirect_to crypto_activities_path, notice: 'Crypto activity was deleted.'
  end

  private
    def set_crypto_activity
      @crypto_activity = current_user.crypto_activities.find(params[:id])
    end

    def crypto_activity_params
      params.require(:crypto_activity).permit(:crypto_currency_id, :activity_type, :crypto_amount, :fiat_amount, :fiat_currency, :fee_crypto, :fee_fiat, :activity_date, :notes)
    end
end
