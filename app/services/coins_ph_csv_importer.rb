# frozen_string_literal: true

require "csv"
require "digest"

class DuplicateFileError < StandardError; end

class CoinsPhCsvImporter
  def initialize(file, user)
    @file = file
    @user = user
  end

  def import!
    content = @file.read
    content_hash = Digest::SHA256.hexdigest(content)

    existing = CryptoActivityImport.find_by(user: @user, content_hash: content_hash)
    raise DuplicateFileError, "This exact file was already imported on #{existing.created_at.strftime('%Y-%m-%d %H:%M')}." if existing

    import = CryptoActivityImport.create!(user: @user, filename: @file.original_filename, status: :pending, content_hash: content_hash)

    rows = parse_csv(content)
    format = detect_format(rows)

    case format
    when :orders
      import_orders_format(import, rows)
    when :spot_trades
      import_spot_trades_format(import, rows)
    else
      raise ArgumentError, "Unsupported CSV format. Expected columns: pair, order_id, side, executed, total, fee (Orders format) or token_id, type, asset_changes (Spot Trades format)."
    end

    if import.import_items.where.not(duplicate_crypto_activity_id: nil).any?
      import.resolving!
    else
      finalize!(import)
    end

    import
  end

  def finalize!(import)
    import.import_items.each do |item|
      next if item.ignore?

      if item.accept? && item.duplicate_crypto_activity.present?
        item.duplicate_crypto_activity.destroy!
      end

      next if item.ignore?

      CryptoActivity.create!(
        user: @user,
        crypto_currency: item.crypto_currency,
        activity_type: item.activity_type,
        crypto_amount: item.crypto_amount,
        fiat_amount: item.fiat_amount,
        fee_crypto: item.fee_crypto || 0,
        fee_fiat: item.fee_fiat || 0,
        activity_date: item.activity_date,
        notes: item.notes,
        crypto_activity_import: import,
      )
    end

    import.completed!
  end

  private

  def parse_csv(content)
    csv = CSV.parse(content, headers: true)
    csv.map(&:to_h)
  end

  def detect_format(rows)
    return :unknown if rows.empty?

    headers = rows.first.keys

    if headers.include?("pair") && headers.include?("order_id") && headers.include?("side")
      :orders
    elsif headers.include?("token_id") && headers.include?("type") && headers.include?("asset_changes")
      :spot_trades
    else
      :unknown
    end
  end

  def import_orders_format(import, rows)
    groups = rows.group_by { |r| r["order_id"] }

    groups.each do |order_id, group_rows|
      item = build_orders_import_item(import, order_id, group_rows)
      duplicate = find_duplicate(item)
      item.update!(duplicate_crypto_activity: duplicate) if duplicate
    end
  end

  def import_spot_trades_format(import, rows)
    groups = rows.group_by { |r| "#{r["created_at"]}|#{r["account_id"]}" }

    groups.each do |group_key, group_rows|
      item = build_spot_trade_import_item(import, group_key, group_rows)
      next if item.nil?

      duplicate = find_duplicate(item)
      item.update!(duplicate_crypto_activity: duplicate) if duplicate
    end
  end

  def build_orders_import_item(import, order_id, group_rows)
    first_row = group_rows.first
    pair = first_row["pair"]
    ticker, quote = pair.split("/")
    crypto_currency = CryptoCurrency.find_by!(ticker: ticker, quote_token: quote)

    side = first_row["side"].to_s.downcase
    activity_type = side == "buy" ? :buy : :sell

    crypto_amount = group_rows.sum { |r| parse_decimal(r["executed"]) }
    fiat_amount = group_rows.sum { |r| parse_decimal(r["total"]) }

    fee_crypto = 0.to_d
    fee_fiat = 0.to_d

    if activity_type == :buy
      fee_crypto = group_rows.sum { |r| parse_fee(r["fee"]) }
    else
      fee_fiat = group_rows.sum { |r| parse_fee(r["fee"]) }
    end

    activity_date = Time.zone.parse(first_row["created_at"]).to_date
    notes = "CoinsPH Import - Order ##{order_id} (#{first_row['order_type']})"

    CryptoActivityImportItem.create!(
      crypto_activity_import: import,
      order_id: order_id,
      crypto_currency: crypto_currency,
      activity_type: activity_type,
      crypto_amount: crypto_amount,
      fiat_amount: fiat_amount,
      fee_crypto: fee_crypto,
      fee_fiat: fee_fiat,
      activity_date: activity_date,
      notes: notes,
      raw_rows: group_rows,
      resolution: :pending,
    )
  end

  def build_spot_trade_import_item(import, group_key, group_rows)
    trade_rows = group_rows.select { |r| r["type"] == "Spot Trade" }
    fee_rows = group_rows.select { |r| r["type"] == "Fees" }

    return nil if trade_rows.empty?

    first_row = trade_rows.first
    ticker = first_row["token_id"]
    crypto_currency = CryptoCurrency.find_by(ticker: ticker, quote_token: "PHP")

    if crypto_currency.nil?
      raise ArgumentError, "No CryptoCurrency found for #{ticker}/PHP. Please create it first."
    end

    asset_change = parse_decimal(first_row["asset_changes"])
    activity_type = asset_change.positive? ? :buy : :sell
    crypto_amount = asset_change.abs

    fee_crypto = fee_rows.sum { |r| parse_decimal(r["asset_changes"]).abs }
    fee_fiat = 0.to_d

    activity_date = Time.zone.parse(first_row["created_at"]).to_date

    estimated_fiat = estimate_fiat_amount(crypto_currency, crypto_amount, activity_date)

    CryptoActivityImportItem.create!(
      crypto_activity_import: import,
      order_id: group_key,
      crypto_currency: crypto_currency,
      activity_type: activity_type,
      crypto_amount: crypto_amount,
      fiat_amount: estimated_fiat,
      fee_crypto: fee_crypto,
      fee_fiat: fee_fiat,
      activity_date: activity_date,
      notes: "CoinsPH Spot Trade Import - verify fiat amount",
      raw_rows: group_rows,
      resolution: :pending,
    )
  end

  def estimate_fiat_amount(crypto_currency, crypto_amount, activity_date)
    price = crypto_currency.last_price
    if price.present? && price.positive?
      return (crypto_amount * price).round(2)
    end

    crypto_amount.round(2)
  end

  def parse_decimal(value)
    value.to_s.strip.to_d
  end

  def parse_fee(fee_str)
    return 0.to_d if fee_str.blank?

    match = fee_str.to_s.match(/([\d.]+)/)
    match ? match[1].to_d : 0.to_d
  end

  def find_duplicate(item)
    candidates = CryptoActivity.where(
      user_id: @user.id,
      crypto_currency_id: item.crypto_currency_id,
      activity_type: item.activity_type,
      activity_date: item.activity_date,
    )

    best_match = nil
    best_score = nil

    candidates.each do |candidate|
      crypto_diff = (candidate.crypto_amount - item.crypto_amount).abs
      fiat_diff = (candidate.fiat_amount - item.fiat_amount).abs

      crypto_tolerance = [candidate.crypto_amount * 0.01, 0.000_01].max
      fiat_tolerance = [candidate.fiat_amount * 0.01, 0.01].max

      next unless crypto_diff <= crypto_tolerance
      next unless fiat_diff <= fiat_tolerance

      score = crypto_diff + fiat_diff
      if best_match.nil? || score < best_score
        best_match = candidate
        best_score = score
      end
    end

    best_match
  end
end
