# frozen_string_literal: true

class StatementImportsController < AuthenticatedUserController
  def index
    @imports = current_user.statement_imports.order(created_at: :desc)
  end

  def new
    @import = StatementImport.new
  end

  def create
    if params[:file].blank?
      redirect_to new_statement_import_path, alert: "Please select a file to upload."
      return
    end

    import = BpiStatementImporter.new(params[:file], current_user).import!

    redirect_to statement_import_path(import), notice: "Statement parsed. Please review the transactions below."
  rescue DuplicateFileError => e
    redirect_to new_statement_import_path, alert: "Duplicate file: #{e.message}"
  rescue StandardError => e
    redirect_to new_statement_import_path, alert: "Import failed: #{e.message}"
  end

  def show
    @import = current_user.statement_imports.find(params[:id])
    @items = @import.statement_import_items.order(:date, :created_at)
  end

  def finalize
    @import = current_user.statement_imports.find(params[:id])

    BpiStatementImporter.new(nil, current_user).finalize!(@import, params[:selected_ids])

    redirect_to statement_import_path(@import), notice: "Import finalized. Activities and dividends created."
  rescue StandardError => e
    redirect_to statement_import_path(@import), alert: "Finalization failed: #{e.message}"
  end
end
