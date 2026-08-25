# frozen_string_literal: true

require "digest"

class DuplicateFileError < StandardError; end

class BpiStatementImporter
  IMPORTABLE_TYPES = %w[buy sell cash_dividend redemption].freeze

  PROMPT = <<~PROMPT
    You are parsing a BPI Trade "Statement of Account" PDF for Philippine Stock Exchange transactions.
    Extract every transaction row from the transaction list into one JSON array. Do not include the portfolio summary section.

    Each array element must be a JSON object with these keys:
    - date: row date in ISO format (YYYY-MM-DD)
    - type: one of buy, sell, cash_dividend, redemption, fee, payment, other
    - ticker: stock ticker symbol, or null
    - shares: whole number of shares, or null
    - price: price per share as a number, or null
    - amount: money amount as a number (see rules below), or null
    - ex_date: ex-dividend date in ISO format, or null
    - ref: the reference number of the row (e.g. BI-..., SI-..., CM-..., OT-..., PV-..., OR-..., SB-...)
    - particulars: the full particulars text of the row

    Mapping rules:
    - "Bought N shares TICKER @PRICE" rows (BI- refs) are buy. amount is the DEBIT column value (total paid including fees).
    - "Sold N shares TICKER @PRICE" rows (SI- refs) are sell. amount is the CREDIT column value (net received after fees).
    - "CASH DIVIDEND TICKER (EXDATE MM/DD/YYYY)" rows (CM- refs) are cash_dividend. amount is the CREDIT column value. Parse the EXDATE into ex_date. The row date is the pay date.
    - "REDEMPTION TICKER (EXDATE ...) N SHARES @PRICE" CM- credit rows are redemption. amount is the CREDIT column value; shares and price come from the particulars. Ignore the matching OT- share-removal row entirely (do not emit it).
    - "IN PAYMENT OF:" rows (PV- or OR- refs) are payment.
    - "PDTC MONTHLY FEES" rows (SB- refs) are fee.
    - Anything else is other.

    Return only the JSON array, no markdown fences, no commentary.
  PROMPT

  def initialize(file, user)
    @file = file
    @user = user
  end

  def import!
    content_hash = Digest::SHA256.hexdigest(@file.read)
    @file.rewind

    existing = StatementImport.where(user: @user, content_hash: content_hash).where.not(status: :failed).first
    raise DuplicateFileError, "This exact file was already imported on #{existing.created_at.strftime('%Y-%m-%d %H:%M')}." if existing

    import = StatementImport.create!(user: @user, filename: @file.original_filename, status: :parsing, content_hash: content_hash)

    transactions = normalize_transactions(GeminiClient.new.extract_structured(PROMPT, @file))
    create_items(import, transactions)
    import.reviewing!
    import
  rescue StandardError => e
    import.update!(status: :failed, error_message: e.message) if import&.parsing?
    raise
  end

  def finalize!(import, selected_ids)
    items = import.statement_import_items.where(id: Array(selected_ids))

    items.each do |item|
      next if item.skipped? || item.duplicate? || item.company.nil?

      if item.cash_dividend?
        @user.cash_dividends.create!(company: item.company, amount: item.amount, pay_date: item.date, ex_date: item.ex_date)
      else
        @user.activities.create!(
          company: item.company,
          activity_type: item.buy? ? "BUY" : "SELL",
          date: item.date,
          number_of_shares: item.shares,
          total_price: item.amount,
          charges: item.charges,
          notes: "Imported from BPI statement #{item.ref}",
        )
      end
    end

    import.completed!
  end

  private

  def create_items(import, transactions)
    transactions.each do |txn|
      next unless txn.is_a?(Hash)

      if IMPORTABLE_TYPES.include?(txn["type"].to_s)
        create_importable_item(import, txn)
      else
        create_skipped_item(import, txn)
      end
    end
  end

  # Gemini sometimes wraps the array in an object, e.g. {"transactions": [...]}.
  def normalize_transactions(parsed)
    return parsed if parsed.is_a?(Array)

    if parsed.is_a?(Hash)
      array = parsed.values.find { |value| value.is_a?(Array) }
      return array if array
    end

    raise "Gemini response did not contain a transactions array: #{parsed.inspect.truncate(500)}"
  end

  def create_skipped_item(import, txn)
    import.statement_import_items.create!(
      item_type: :skipped,
      selected: false,
      date: parse_date(txn["date"]),
      ticker: txn["ticker"],
      amount: txn["amount"],
      ref: txn["ref"],
      particulars: txn["particulars"],
      note: "Skipped: #{skip_reason(txn['type'])}",
    )
  end

  def create_importable_item(import, txn)
    ticker = txn["ticker"].to_s
    company = ticker.present? ? Company.find_by(ticker: ticker) : nil

    note = nil
    selected = true
    if company.nil?
      note = "Unknown ticker #{ticker.presence || '(none)'}"
      selected = false
    end

    item = import.statement_import_items.create!(
      item_type: txn["type"],
      selected: selected,
      date: parse_date(txn["date"]),
      ticker: ticker,
      shares: txn["shares"],
      price: txn["price"],
      amount: txn["amount"],
      charges: compute_charges(txn),
      ex_date: parse_date(txn["ex_date"]),
      ref: txn["ref"],
      particulars: txn["particulars"],
      company: company,
      note: note,
    )

    flag_duplicate(item)
  end

  def skip_reason(type)
    case type.to_s
    when "fee" then "PDTC fee"
    when "payment" then "Payment leg"
    else "Unrecognized row"
    end
  end

  # Trades settle at shares x price; the gap against the actual debit/credit is the fees.
  def compute_charges(txn)
    return nil if txn["type"].to_s == "cash_dividend"
    return nil if txn["shares"].nil? || txn["price"].nil? || txn["amount"].nil?

    (txn["shares"].to_d * txn["price"].to_d - txn["amount"].to_d).abs
  end

  def flag_duplicate(item)
    return if item.company.nil?

    duplicate = item.cash_dividend? ? dividend_duplicate?(item) : activity_duplicate?(item)
    return unless duplicate

    note = [item.note, "Possible duplicate of an existing record"].compact.join("; ")
    item.update!(duplicate: true, selected: false, note: note)
  end

  def activity_duplicate?(item)
    @user.activities.where(company: item.company, date: item.date, number_of_shares: item.shares).any? do |activity|
      within_one_percent?(activity.total_price, item.amount)
    end
  end

  def dividend_duplicate?(item)
    @user.cash_dividends.where(company: item.company, pay_date: item.date).any? do |dividend|
      within_one_percent?(dividend.amount, item.amount)
    end
  end

  def within_one_percent?(existing_amount, new_amount)
    return false if existing_amount.nil? || new_amount.nil?

    (existing_amount.to_d - new_amount.to_d).abs <= existing_amount.to_d.abs * 0.01
  end

  def parse_date(value)
    return nil if value.blank?

    Date.iso8601(value.to_s)
  rescue Date::Error
    nil
  end
end
