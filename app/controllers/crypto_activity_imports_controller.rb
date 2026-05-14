# frozen_string_literal: true

class CryptoActivityImportsController < AuthenticatedUserController
  def index
    @imports = current_user.crypto_activity_imports.order(created_at: :desc)
  end

  def new
    @import = CryptoActivityImport.new
  end

  def create
    if params[:file].blank?
      redirect_to new_crypto_activity_import_path, alert: "Please select a file to upload."
      return
    end

    importer = CoinsPhCsvImporter.new(params[:file], current_user)
    import = importer.import!

    if import.resolving?
      redirect_to crypto_activity_import_path(import), notice: "Import processed. Please review potential duplicates."
    else
      redirect_to crypto_activity_import_path(import), notice: "Import completed successfully with no duplicates."
    end
  rescue DuplicateFileError => e
    redirect_to new_crypto_activity_import_path, alert: "Duplicate file: #{e.message}"
  rescue => e
    redirect_to new_crypto_activity_import_path, alert: "Import failed: #{e.message}"
  end

  def show
    @import = current_user.crypto_activity_imports.find(params[:id])
    @items = @import.import_items.includes(:crypto_currency, duplicate_crypto_activity: :crypto_currency)

    respond_to do |format|
      format.html
      format.json { render json: import_json }
    end
  end

  def resolve
    @import = current_user.crypto_activity_imports.find(params[:id])
    @item = @import.import_items.find(params[:item_id])

    resolution = params[:resolution]
    if %w[accept ignore].include?(resolution)
      @item.update!(resolution: resolution)
    end

    respond_to do |format|
      format.html { redirect_to crypto_activity_import_path(@import), notice: "Resolution updated." }
      format.json { render json: { success: true, item: import_item_json(@item) } }
    end
  end

  def finalize
    @import = current_user.crypto_activity_imports.find(params[:id])

    if @import.unresolved_duplicates?
      respond_to do |format|
        format.html { redirect_to crypto_activity_import_path(@import), alert: "Please resolve all duplicates before finalizing." }
        format.json { render json: { error: "Please resolve all duplicates before finalizing." }, status: :unprocessable_entity }
      end
      return
    end

    importer = CoinsPhCsvImporter.new(nil, current_user)
    importer.finalize!(@import)

    respond_to do |format|
      format.html { redirect_to crypto_activity_import_path(@import), notice: "Import finalized successfully." }
      format.json { render json: { success: true, redirect_url: crypto_activity_import_url(@import) } }
    end
  rescue => e
    respond_to do |format|
      format.html { redirect_to crypto_activity_import_path(@import), alert: "Finalization failed: #{e.message}" }
      format.json { render json: { error: e.message }, status: :unprocessable_entity }
    end
  end

  def destroy
    @import = current_user.crypto_activity_imports.find(params[:id])

    if @import.completed?
      redirect_to crypto_activity_imports_path, alert: "Cannot delete a completed import."
      return
    end

    @import.destroy!
    redirect_to crypto_activity_imports_path, notice: "Import was successfully deleted."
  end

  private

  def import_json
    {
      import: {
        id: @import.id,
        filename: @import.filename,
        status: @import.status,
        created_at: @import.created_at,
        created_activities_count: @import.crypto_activities.count,
      },
      items: @items.map { |item| import_item_json(item) },
    }
  end

  def import_item_json(item)
    {
      id: item.id,
      order_id: item.order_id,
      activity_type: item.activity_type,
      activity_date: item.activity_date,
      crypto_amount: item.crypto_amount.to_s,
      fiat_amount: item.fiat_amount.to_s,
      fee_crypto: item.fee_crypto.to_s,
      fee_fiat: item.fee_fiat.to_s,
      notes: item.notes,
      resolution: item.resolution,
      raw_rows: item.raw_rows,
      crypto_currency: item.crypto_currency ? {
        ticker: item.crypto_currency.ticker,
        quote_token: item.crypto_currency.quote_token,
        compound_ticker: item.crypto_currency.compound_ticker,
        pretty_ticker: item.crypto_currency.pretty_ticker,
      } : nil,
      duplicate: item.duplicate_crypto_activity ? {
        id: item.duplicate_crypto_activity.id,
        activity_type: item.duplicate_crypto_activity.activity_type,
        activity_date: item.duplicate_crypto_activity.activity_date,
        crypto_amount: item.duplicate_crypto_activity.crypto_amount.to_s,
        fiat_amount: item.duplicate_crypto_activity.fiat_amount.to_s,
        fee_crypto: item.duplicate_crypto_activity.fee_crypto.to_s,
        fee_fiat: item.duplicate_crypto_activity.fee_fiat.to_s,
        notes: item.duplicate_crypto_activity.notes,
        crypto_currency: item.duplicate_crypto_activity.crypto_currency ? {
          ticker: item.duplicate_crypto_activity.crypto_currency.ticker,
          quote_token: item.duplicate_crypto_activity.crypto_currency.quote_token,
          compound_ticker: item.duplicate_crypto_activity.crypto_currency.compound_ticker,
          pretty_ticker: item.duplicate_crypto_activity.crypto_currency.pretty_ticker,
        } : nil,
      } : nil,
    }
  end
end
