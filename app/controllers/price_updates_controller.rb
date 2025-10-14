# frozen_string_literal: true

class PriceUpdatesController < AuthenticatedUserController
  before_action :set_price_update, only: %i[show edit update destroy]

  # GET /price_updates
  # GET /price_updates.json
  def index
    @price_updates = PriceUpdate.latest_first.first(300)
  end

  # GET /price_updates/1
  # GET /price_updates/1.json
  def show; end

  # GET /price_updates/new
  def new
    @price_update = PriceUpdate.new
  end

  # GET /price_updates/1/edit
  def edit; end

  # POST /price_updates
  # POST /price_updates.json
  def create
    @price_update = PriceUpdate.new(price_update_params)

    respond_to do |format|
      if @price_update.save
        format.html { redirect_to new_price_update_path, notice: "#{@price_update.company} @ #{@price_update.price} was successfully created." }
        format.json { render :show, status: :created, location: @price_update }
      else
        format.html { render :new }
        format.json { render json: @price_update.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /price_updates/1
  # PATCH/PUT /price_updates/1.json
  def update
    respond_to do |format|
      if @price_update.update(price_update_params)
        format.html { redirect_to @price_update, notice: 'Price update was successfully updated.' }
        format.json { render :show, status: :ok, location: @price_update }
      else
        format.html { render :edit }
        format.json { render json: @price_update.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /price_updates/1
  # DELETE /price_updates/1.json
  def destroy
    @price_update.destroy
    respond_to do |format|
      format.html { redirect_to price_updates_url, notice: 'Price update was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_price_update
    @price_update = PriceUpdate.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def price_update_params
    params.require(:price_update).permit(:company_id, :datetime, :price)
  end
end
