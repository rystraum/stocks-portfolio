# frozen_string_literal: true

require "test_helper"

class CoinsPhCsvImporterTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(email: "test@example.com", password: "password123")
    @crypto = CryptoCurrency.create!(name: "Ethereum", ticker: "ETH", quote_token: "PHP", datasource_ticker: "ETHPHP")
  end

  def sample_csv_file
    path = Rails.root.join("test/fixtures/files/coins_ph_sample.csv")
    ActionDispatch::Http::UploadedFile.new(
      tempfile: File.open(path),
      filename: "coins_ph_sample.csv",
      type: "text/csv",
    )
  end

  test "imports grouped transactions from csv without duplicates" do
    importer = CoinsPhCsvImporter.new(sample_csv_file, @user)
    import = importer.import!

    assert import.completed?
    assert_equal 2, import.import_items.count

    buy_item = import.import_items.find_by(order_id: "2107896828699304449")
    assert buy_item.buy?
    assert_equal 0.011998.to_d, buy_item.crypto_amount
    assert_equal 1999.92.to_d, buy_item.fiat_amount
    assert buy_item.fee_crypto.positive?

    sell_item = import.import_items.find_by(order_id: "2053117749639209474")
    assert sell_item.sell?
    assert_equal 0.017021.to_d, sell_item.crypto_amount
    assert_equal 4411.34.to_d, sell_item.fiat_amount
    assert sell_item.fee_fiat.positive?

    assert_equal 2, import.crypto_activities.count
  end

  test "detects duplicates when existing activity matches" do
    CryptoActivity.create!(
      user: @user,
      crypto_currency: @crypto,
      activity_type: :buy,
      crypto_amount: 0.012,
      fiat_amount: 2000.00,
      fiat_currency: "PHP",
      activity_date: Date.new(2025, 12, 18),
    )

    importer = CoinsPhCsvImporter.new(sample_csv_file, @user)
    import = importer.import!

    assert import.resolving?
    buy_item = import.import_items.find_by(order_id: "2107896828699304449")
    assert buy_item.duplicate_crypto_activity.present?
  end

  test "finalize creates activities and deletes duplicates on accept" do
    existing = CryptoActivity.create!(
      user: @user,
      crypto_currency: @crypto,
      activity_type: :buy,
      crypto_amount: 0.012,
      fiat_amount: 2000.00,
      fiat_currency: "PHP",
      activity_date: Date.new(2025, 12, 18),
    )

    importer = CoinsPhCsvImporter.new(sample_csv_file, @user)
    import = importer.import!

    buy_item = import.import_items.find_by(order_id: "2107896828699304449")
    buy_item.update!(resolution: :accept)

    sell_item = import.import_items.find_by(order_id: "2053117749639209474")
    sell_item.update!(resolution: :accept)

    importer.finalize!(import)

    assert import.completed?
    assert_equal 2, import.crypto_activities.count
    assert_raises(ActiveRecord::RecordNotFound) { existing.reload }
  end

  test "finalize skips ignored items" do
    CryptoActivity.create!(
      user: @user,
      crypto_currency: @crypto,
      activity_type: :buy,
      crypto_amount: 0.012,
      fiat_amount: 2000.00,
      fiat_currency: "PHP",
      activity_date: Date.new(2025, 12, 18),
    )

    importer = CoinsPhCsvImporter.new(sample_csv_file, @user)
    import = importer.import!

    assert import.resolving?
    import.import_items.each { |i| i.update!(resolution: :ignore) }
    importer.finalize!(import)

    assert import.completed?
    assert_equal 0, import.crypto_activities.count
  end

  test "raises DuplicateFileError when importing the same file twice" do
    importer = CoinsPhCsvImporter.new(sample_csv_file, @user)
    import = importer.import!
    assert import.completed?

    assert_raises(DuplicateFileError) do
      CoinsPhCsvImporter.new(sample_csv_file, @user).import!
    end
  end
end
