# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2025_09_24_053155) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "activities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.bigint "old_id"
    t.bigint "old_company_id"
    t.string "activity_type"
    t.integer "number_of_shares"
    t.decimal "total_price", precision: 15, scale: 2
    t.date "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "charges", precision: 15, scale: 4
    t.bigint "old_user_id"
    t.text "notes"
    t.uuid "user_id"
    t.uuid "company_id"
    t.index ["activity_type"], name: "index_activities_on_activity_type"
    t.index ["old_company_id"], name: "index_activities_on_old_company_id"
    t.index ["user_id"], name: "index_activities_on_user_id"
  end

  create_table "cash_dividends", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.bigint "old_id"
    t.bigint "old_company_id"
    t.decimal "amount", precision: 15, scale: 2
    t.date "pay_date"
    t.date "ex_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "meta"
    t.bigint "old_user_id"
    t.bigint "old_last_price_update_id"
    t.uuid "user_id"
    t.uuid "last_price_update_id"
    t.uuid "company_id"
    t.index ["old_company_id"], name: "index_cash_dividends_on_old_company_id"
    t.index ["old_last_price_update_id"], name: "index_cash_dividends_on_old_last_price_update_id"
    t.index ["user_id"], name: "index_cash_dividends_on_user_id"
  end

  create_table "companies", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.bigint "old_id"
    t.string "ticker"
    t.string "industry"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "inactive", default: false
    t.string "pse_security_id"
    t.string "pse_company_id"
    t.string "name"
    t.decimal "target_buy_price", precision: 15, scale: 2
    t.string "target_price_note"
    t.integer "dividend_frequency_months"
    t.index ["industry"], name: "index_companies_on_industry"
    t.index ["ticker"], name: "index_companies_on_ticker", unique: true
  end

  create_table "converted_announcements", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.bigint "old_id"
    t.uuid "dividend_announcement_id"
    t.uuid "user_id"
    t.uuid "cash_dividend_id"
    t.bigint "old_user_id"
    t.bigint "old_cash_dividend_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "crypto_activities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.uuid "crypto_currency_id", null: false
    t.integer "activity_type", null: false
    t.decimal "crypto_amount", precision: 30, scale: 20, null: false
    t.decimal "fiat_amount", precision: 18, scale: 2, null: false
    t.string "fiat_currency", null: false
    t.decimal "fee_crypto", precision: 30, scale: 20, default: "0.0"
    t.date "activity_date", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.decimal "fee_fiat", precision: 18, scale: 2, default: "0.0"
    t.text "notes"
    t.index ["activity_type"], name: "index_crypto_activities_on_activity_type"
    t.index ["crypto_currency_id"], name: "index_crypto_activities_on_crypto_currency_id"
    t.index ["user_id"], name: "index_crypto_activities_on_user_id"
  end

  create_table "crypto_currencies", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "ticker", null: false
    t.decimal "last_price", precision: 30, scale: 20
    t.datetime "last_price_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "datasource", default: "https://api.pro.coins.ph/"
    t.string "datasource_ticker"
    t.index ["ticker"], name: "index_crypto_currencies_on_ticker", unique: true
  end

  create_table "dividend_announcements", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.bigint "old_id"
    t.uuid "company_id", null: false
    t.string "share_class"
    t.string "dividend_type"
    t.decimal "amount"
    t.date "ex_date"
    t.date "record_date"
    t.date "payout_date"
    t.string "circular_number"
    t.string "raw_html"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["circular_number"], name: "index_dividend_announcements_on_circular_number", unique: true
    t.index ["company_id"], name: "index_dividend_announcements_on_company_id"
  end

  create_table "price_updates", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.bigint "old_id"
    t.bigint "old_company_id"
    t.datetime "datetime"
    t.decimal "price", precision: 15, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "notes"
    t.uuid "company_id"
    t.index ["old_company_id"], name: "index_price_updates_on_old_company_id"
  end

  create_table "stock_dividends", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.bigint "old_id"
    t.bigint "old_company_id"
    t.integer "amount"
    t.date "pay_date"
    t.date "ex_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "old_user_id"
    t.bigint "old_last_price_update_id"
    t.uuid "user_id"
    t.uuid "last_price_update_id"
    t.uuid "company_id"
    t.index ["old_company_id"], name: "index_stock_dividends_on_old_company_id"
    t.index ["old_last_price_update_id"], name: "index_stock_dividends_on_old_last_price_update_id"
    t.index ["user_id"], name: "index_stock_dividends_on_user_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.bigint "old_id"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "activities", "companies"
  add_foreign_key "activities", "users"
  add_foreign_key "cash_dividends", "companies"
  add_foreign_key "cash_dividends", "price_updates", column: "last_price_update_id"
  add_foreign_key "cash_dividends", "users"
  add_foreign_key "converted_announcements", "cash_dividends"
  add_foreign_key "converted_announcements", "dividend_announcements"
  add_foreign_key "converted_announcements", "users"
  add_foreign_key "crypto_activities", "crypto_currencies"
  add_foreign_key "crypto_activities", "users"
  add_foreign_key "dividend_announcements", "companies"
  add_foreign_key "price_updates", "companies"
  add_foreign_key "stock_dividends", "companies"
  add_foreign_key "stock_dividends", "price_updates", column: "last_price_update_id"
  add_foreign_key "stock_dividends", "users"
end
