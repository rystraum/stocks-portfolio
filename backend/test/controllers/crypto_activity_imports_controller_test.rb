# frozen_string_literal: true

require "test_helper"

class CryptoActivityImportsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(email: "test@example.com", password: "password123")
    @crypto = CryptoCurrency.create!(name: "Ethereum", ticker: "ETH", quote_token: "PHP", datasource_ticker: "ETHPHP")
    sign_in @user
  end

  test "should get index" do
    get crypto_activity_imports_url
    assert_response :success
  end

  test "should get new" do
    get new_crypto_activity_import_url
    assert_response :success
  end

  test "should create import without duplicates" do
    assert_difference("CryptoActivityImport.count") do
      post crypto_activity_imports_url, params: { file: fixture_file_upload("coins_ph_sample.csv", "text/csv") }
    end

    import = CryptoActivityImport.last
    assert_redirected_to crypto_activity_import_path(import)
    assert import.completed?
    assert_equal 2, import.crypto_activities.count
  end

  test "should create import with duplicates and show resolving" do
    CryptoActivity.create!(
      user: @user,
      crypto_currency: @crypto,
      activity_type: :buy,
      crypto_amount: 0.012,
      fiat_amount: 2000.00,
      fiat_currency: "PHP",
      activity_date: Date.new(2025, 12, 18),
    )

    post crypto_activity_imports_url, params: { file: fixture_file_upload("coins_ph_sample.csv", "text/csv") }

    import = CryptoActivityImport.last
    assert_redirected_to crypto_activity_import_path(import)
    assert import.resolving?
  end

  test "should resolve duplicate" do
    file = fixture_file_upload("coins_ph_sample.csv", "text/csv")
    importer = CoinsPhCsvImporter.new(file, @user)
    import = importer.import!

    item = import.import_items.first
    post resolve_crypto_activity_import_path(import), params: { item_id: item.id, resolution: "accept" }
    assert_redirected_to crypto_activity_import_path(import)
    item.reload
    assert item.accept?
  end

  test "should finalize import" do
    file = fixture_file_upload("coins_ph_sample.csv", "text/csv")
    importer = CoinsPhCsvImporter.new(file, @user)
    import = importer.import!

    import.import_items.each { |i| i.update!(resolution: :accept) }

    post finalize_crypto_activity_import_path(import)
    assert_redirected_to crypto_activity_import_path(import)
    import.reload
    assert import.completed?
  end

  test "should not finalize with unresolved duplicates" do
    CryptoActivity.create!(
      user: @user,
      crypto_currency: @crypto,
      activity_type: :buy,
      crypto_amount: 0.012,
      fiat_amount: 2000.00,
      fiat_currency: "PHP",
      activity_date: Date.new(2025, 12, 18),
    )

    file = fixture_file_upload("coins_ph_sample.csv", "text/csv")
    importer = CoinsPhCsvImporter.new(file, @user)
    import = importer.import!

    post finalize_crypto_activity_import_path(import)
    assert_redirected_to crypto_activity_import_path(import)
    import.reload
    assert import.resolving?
  end

  test "should return JSON for show" do
    file = fixture_file_upload("coins_ph_sample.csv", "text/csv")
    importer = CoinsPhCsvImporter.new(file, @user)
    import = importer.import!

    get crypto_activity_import_path(import), as: :json
    assert_response :success
    body = JSON.parse(response.body)
    assert_equal import.id, body["import"]["id"]
    assert_equal 2, body["items"].length
  end

  test "should resolve duplicate via JSON" do
    file = fixture_file_upload("coins_ph_sample.csv", "text/csv")
    importer = CoinsPhCsvImporter.new(file, @user)
    import = importer.import!

    item = import.import_items.first
    post resolve_crypto_activity_import_path(import), params: { item_id: item.id, resolution: "accept" }, as: :json
    assert_response :success
    body = JSON.parse(response.body)
    assert body["success"]
    item.reload
    assert item.accept?
  end

  test "should finalize import via JSON" do
    file = fixture_file_upload("coins_ph_sample.csv", "text/csv")
    importer = CoinsPhCsvImporter.new(file, @user)
    import = importer.import!

    import.import_items.each { |i| i.update!(resolution: :accept) }

    post finalize_crypto_activity_import_path(import), as: :json
    assert_response :success
    body = JSON.parse(response.body)
    assert body["success"]
    assert body["redirect_url"].present?
    import.reload
    assert import.completed?
  end

  test "should not finalize unresolved duplicates via JSON" do
    CryptoActivity.create!(
      user: @user,
      crypto_currency: @crypto,
      activity_type: :buy,
      crypto_amount: 0.012,
      fiat_amount: 2000.00,
      fiat_currency: "PHP",
      activity_date: Date.new(2025, 12, 18),
    )

    file = fixture_file_upload("coins_ph_sample.csv", "text/csv")
    importer = CoinsPhCsvImporter.new(file, @user)
    import = importer.import!

    post finalize_crypto_activity_import_path(import), as: :json
    assert_response :unprocessable_entity
    body = JSON.parse(response.body)
    assert body["error"].present?
  end

  test "should reject duplicate file upload" do
    post crypto_activity_imports_url, params: { file: fixture_file_upload("coins_ph_sample.csv", "text/csv") }
    assert_redirected_to crypto_activity_import_path(CryptoActivityImport.last)

    post crypto_activity_imports_url, params: { file: fixture_file_upload("coins_ph_sample.csv", "text/csv") }
    assert_redirected_to new_crypto_activity_import_path
    assert_match /Duplicate file/, flash[:alert]
  end

  test "should delete non-completed import" do
    CryptoActivity.create!(
      user: @user,
      crypto_currency: @crypto,
      activity_type: :buy,
      crypto_amount: 0.012,
      fiat_amount: 2000.00,
      fiat_currency: "PHP",
      activity_date: Date.new(2025, 12, 18),
    )

    file = fixture_file_upload("coins_ph_sample.csv", "text/csv")
    importer = CoinsPhCsvImporter.new(file, @user)
    import = importer.import!
    assert import.resolving?

    assert_difference("CryptoActivityImport.count", -1) do
      delete crypto_activity_import_path(import)
    end

    assert_redirected_to crypto_activity_imports_path
    assert_match /successfully deleted/, flash[:notice]
  end

  test "should not delete completed import" do
    file = fixture_file_upload("coins_ph_sample.csv", "text/csv")
    importer = CoinsPhCsvImporter.new(file, @user)
    import = importer.import!
    assert import.completed?

    assert_no_difference("CryptoActivityImport.count") do
      delete crypto_activity_import_path(import)
    end

    assert_redirected_to crypto_activity_imports_path
    assert_match /Cannot delete a completed import/, flash[:alert]
  end
end
