# frozen_string_literal: true

class ActivitiesController < AuthenticatedUserController
  before_action :set_activity, only: %i[show edit update destroy convert_planned]

  # GET /activities
  # GET /activities.json
  def index
    @activities = current_user.activities.order("date desc")
  end

  # GET /activities/1
  # GET /activities/1.json
  def show
    return if @permissions.can?(:view, @activity)

    return redirect_back(fallback_location: @activity, alert: "No permissions")
  end

  # GET /activities/new
  def new
    @activity = Activity.new(company: Company.find_by(ticker: params[:ticker]), date: Time.zone.today)
  end

  # GET /activities/1/edit
  def edit
    return if @permissions.can?(:update, @activity)

    return redirect_back(fallback_location: @activity, alert: "No permissions")
  end

  # POST /activities
  # POST /activities.json
  def create
    @activity = current_user.activities.build(activity_params)

    respond_to do |format|
      if @activity.save
        format.html { redirect_to @activity, notice: "Activity was successfully created." }
        format.json { render :show, status: :created, location: @activity }
      else
        format.html { render :new }
        format.json { render json: @activity.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /activities/1
  # PATCH/PUT /activities/1.json
  def update
    return redirect_back(fallback_location: @activity, alert: "No permissions") unless @permissions.can?(:update, @activity)

    respond_to do |format|
      if @activity.update(activity_params)
        format.html { redirect_to @activity, notice: "Activity was successfully updated." }
        format.json { render :show, status: :ok, location: @activity }
      else
        format.html { render :edit }
        format.json { render json: @activity.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /activities/1
  # DELETE /activities/1.json
  def destroy
    return redirect_back(fallback_location: @activity, alert: "No permissions") unless @permissions.can?(:delete, @activity)

    @activity.destroy
    respond_to do |format|
      format.html { redirect_to activities_url, notice: "Activity was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def convert_planned
    return redirect_back(fallback_location: @activity, alert: "No permissions") unless @permissions.can?(:update, @activity)

    @activity.convert_planned!
    respond_to do |format|
      format.html { redirect_to activities_url, notice: "Activity converted to #{@activity.activity_type}" }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_activity
    @activity = current_user.activities.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def activity_params
    hash = params.require(:activity).permit(:company_id, :activity_type, :number_of_shares, :total_price, :date, :charges, :notes)
    hash[:total_price] = hash[:total_price].gsub(",", "")
    return hash
  end
end
