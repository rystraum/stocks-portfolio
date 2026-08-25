# frozen_string_literal: true

require "test_helper"

class BpiStatementImporterTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(email: "bpi-import@example.com", password: "password123")
    @dmc = Company.create!(ticker: "DMC")
    @acen = Company.create!(ticker: "ACEN")
    @smc2i = Company.create!(ticker: "SMC2I")
  end

  test "import! creates classified items with computed charges" do
    stub_gemini_extract(parsed_transactions) do
      import = BpiStatementImporter.new(fake_file, @user).import!

      assert import.reviewing?
      items = import.statement_import_items
      assert_equal 7, items.count

      buy = items.find_by(item_type: :buy, ticker: "DMC")
      assert_equal @dmc, buy.company
      assert_equal Date.new(2026, 6, 2), buy.date
      assert_equal 2000, buy.shares
      assert_equal 11.58, buy.price.to_f
      assert_equal 23_228.32, buy.amount.to_f
      assert_in_delta 68.32, buy.charges.to_f
      assert buy.selected?
      assert_not buy.duplicate?

      sell = items.find_by(item_type: :sell, ticker: "ACEN")
      assert_in_delta 34.50, sell.charges.to_f

      redemption = items.find_by(item_type: :redemption, ticker: "SMC2I")
      assert_equal 150, redemption.shares
      assert_in_delta 0.0, redemption.charges.to_f
    end
  end

  test "import! creates dividend and skipped items" do
    stub_gemini_extract(parsed_transactions) do
      import = BpiStatementImporter.new(fake_file, @user).import!

      dividend = import.statement_import_items.find_by(item_type: :cash_dividend, ticker: "DMC")
      assert_equal Date.new(2026, 5, 20), dividend.ex_date
      assert_nil dividend.charges

      skipped = import.statement_import_items.where(item_type: :skipped)
      assert_equal 2, skipped.count
      assert(skipped.all? { |item| !item.selected? })
    end
  end

  test "import! marks unknown tickers unselected with a note" do
    stub_gemini_extract(parsed_transactions) do
      import = BpiStatementImporter.new(fake_file, @user).import!

      unknown = import.statement_import_items.find_by(ticker: "UNKNOWN")
      assert_nil unknown.company
      assert_not unknown.selected?
      assert_match(/Unknown ticker/, unknown.note)
    end
  end

  test "import! flags duplicates of existing activities and dividends" do
    @user.activities.create!(company: @dmc, activity_type: "BUY", date: Date.new(2026, 6, 2), number_of_shares: 2000, total_price: 23_228.00)
    @user.cash_dividends.create!(company: @dmc, amount: 480.00, pay_date: Date.new(2026, 6, 15), ex_date: Date.new(2026, 5, 20))

    stub_gemini_extract(parsed_transactions) do
      import = BpiStatementImporter.new(fake_file, @user).import!

      duplicate_buy = import.statement_import_items.find_by(item_type: :buy, ticker: "DMC")
      assert duplicate_buy.duplicate?
      assert_not duplicate_buy.selected?
      assert_match(/duplicate/i, duplicate_buy.note)

      duplicate_dividend = import.statement_import_items.find_by(item_type: :cash_dividend)
      assert duplicate_dividend.duplicate?

      sell = import.statement_import_items.find_by(item_type: :sell)
      assert_not sell.duplicate?
    end
  end

  test "import! raises DuplicateFileError for the same file content" do
    stub_gemini_extract(parsed_transactions) do
      BpiStatementImporter.new(fake_file, @user).import!

      assert_raises(DuplicateFileError) { BpiStatementImporter.new(fake_file, @user).import! }
    end
  end

  test "import! marks the import failed and re-raises when parsing fails" do
    stub_gemini_extract_error("API down") do
      assert_raises(RuntimeError) { BpiStatementImporter.new(fake_file, @user).import! }
    end

    import = @user.statement_imports.last
    assert import.failed?
    assert_equal "API down", import.error_message
  end

  test "finalize! creates activities and dividends for selected items only" do
    stub_gemini_extract(parsed_transactions) do
      import = BpiStatementImporter.new(fake_file, @user).import!

      sell_item = import.statement_import_items.find_by(item_type: :sell)
      selected = import.statement_import_items.where(selected: true).where.not(id: sell_item.id).pluck(:id)

      BpiStatementImporter.new(nil, @user).finalize!(import, selected)

      assert import.reload.completed?

      buy_activity = @user.activities.find_by(company: @dmc, activity_type: "BUY")
      assert_equal Date.new(2026, 6, 2), buy_activity.date
      assert_equal 2000, buy_activity.number_of_shares
      assert_equal 23_228.32, buy_activity.total_price.to_f
      assert_in_delta 68.32, buy_activity.charges.to_f
      assert_equal "Imported from BPI statement BI-123", buy_activity.notes

      redemption_activity = @user.activities.find_by(company: @smc2i)
      assert_equal "SELL", redemption_activity.activity_type
      assert_equal 150, redemption_activity.number_of_shares
      assert_equal 11_250.00, redemption_activity.total_price.to_f

      assert_nil @user.activities.find_by(company: @acen)

      dividend = @user.cash_dividends.find_by(company: @dmc)
      assert_equal 480.00, dividend.amount.to_f
      assert_equal Date.new(2026, 6, 15), dividend.pay_date
      assert_equal Date.new(2026, 5, 20), dividend.ex_date

      assert_equal 2, @user.activities.count
      assert_equal 1, @user.cash_dividends.count
    end
  end

  test "finalize! skips duplicate items even when selected" do
    @user.activities.create!(company: @dmc, activity_type: "BUY", date: Date.new(2026, 6, 2), number_of_shares: 2000, total_price: 23_228.00)

    stub_gemini_extract(parsed_transactions) do
      import = BpiStatementImporter.new(fake_file, @user).import!
      duplicate_item = import.statement_import_items.find_by(item_type: :buy, ticker: "DMC")

      BpiStatementImporter.new(nil, @user).finalize!(import, [duplicate_item.id])

      assert_equal 1, @user.activities.where(company: @dmc).count
      assert import.reload.completed?
    end
  end

  private

  def parsed_transactions
    [
      { "date" => "2026-06-02", "type" => "buy", "ticker" => "DMC", "shares" => 2000, "price" => 11.58, "amount" => 23_228.32, "ref" => "BI-123",
        "particulars" => "Bought 2,000 shares DMC @11.5800" },
      { "date" => "2026-06-10", "type" => "sell", "ticker" => "ACEN", "shares" => 1000, "price" => 2.85, "amount" => 2_815.50, "ref" => "SI-456",
        "particulars" => "Sold 1,000 shares ACEN @2.8500" },
      { "date" => "2026-06-15", "type" => "cash_dividend", "ticker" => "DMC", "amount" => 480.00, "ex_date" => "2026-05-20", "ref" => "CM-789",
        "particulars" => "CASH DIVIDEND DMC (EXDATE 05/20/2026)" },
      { "date" => "2026-03-31", "type" => "redemption", "ticker" => "SMC2I", "shares" => 150, "price" => 75.0, "amount" => 11_250.00, "ref" => "CM-999",
        "particulars" => "REDEMPTION SMC2I (EXDATE 03/31/2026) 150 SHARES @75." },
      { "date" => "2026-06-30", "type" => "fee", "amount" => 25.00, "ref" => "SB-111", "particulars" => "PDTC MONTHLY FEES" },
      { "date" => "2026-06-03", "type" => "payment", "amount" => 23_228.32, "ref" => "OR-222", "particulars" => "IN PAYMENT OF: BI-123" },
      { "date" => "2026-06-20", "type" => "buy", "ticker" => "UNKNOWN", "shares" => 10, "price" => 5.0, "amount" => 50.25, "ref" => "BI-333",
        "particulars" => "Bought 10 shares UNKNOWN @5.0000" },
    ]
  end

  def fake_file(content = "%PDF-synthetic")
    file = StringIO.new(content)
    file.define_singleton_method(:original_filename) { "Statement_of_Account_Test.pdf" }
    file
  end

  def stub_gemini_extract(transactions)
    original = GeminiClient.instance_method(:extract_structured)
    GeminiClient.define_method(:extract_structured) { |_prompt, _pdf_io| transactions }
    yield
  ensure
    GeminiClient.define_method(:extract_structured, original)
  end

  def stub_gemini_extract_error(message)
    original = GeminiClient.instance_method(:extract_structured)
    GeminiClient.define_method(:extract_structured) { |_prompt, _pdf_io| raise message }
    yield
  ensure
    GeminiClient.define_method(:extract_structured, original)
  end
end
