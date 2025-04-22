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

ActiveRecord::Schema.define(version: 2025_04_22_112000) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "activities", force: :cascade do |t|
    t.date "date"
    t.integer "company_id"
    t.string "activity_type"
    t.integer "number_of_shares"
    t.decimal "total_price", precision: 15, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "charges", precision: 15, scale: 4
    t.bigint "user_id"
    t.text "notes"
    t.index ["activity_type"], name: "index_activities_on_activity_type"
    t.index ["company_id"], name: "index_activities_on_company_id"
    t.index ["user_id"], name: "index_activities_on_user_id"
  end

  create_table "cash_dividends", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.bigint "old_id"
    t.bigint "company_id"
    t.decimal "amount", precision: 15, scale: 2
    t.date "pay_date"
    t.date "ex_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "meta"
    t.bigint "user_id"
    t.bigint "last_price_update_id"
    t.index ["company_id"], name: "index_cash_dividends_on_company_id"
    t.index ["last_price_update_id"], name: "index_cash_dividends_on_last_price_update_id"
    t.index ["user_id"], name: "index_cash_dividends_on_user_id"
  end

  create_table "companies", force: :cascade do |t|
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

  create_table "converted_announcements", force: :cascade do |t|
    t.bigint "dividend_announcement_id"
    t.bigint "user_id"
    t.bigint "old_cash_dividend_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.uuid "cash_dividend_id"
    t.index ["cash_dividend_id"], name: "index_converted_announcements_on_cash_dividend_id"
    t.index ["dividend_announcement_id", "user_id"], name: "index_converted_dx_user_id", unique: true
    t.index ["dividend_announcement_id"], name: "index_converted_announcements_on_dividend_announcement_id"
    t.index ["user_id"], name: "index_converted_announcements_on_user_id"
  end

  create_table "crypto_currencies", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "ticker", null: false
    t.integer "last_price"
    t.datetime "last_price_at"
    t.integer "decimal_places", default: 8, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["ticker"], name: "index_crypto_currencies_on_ticker", unique: true
  end

  create_table "dividend_announcements", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.string "share_class"
    t.string "dividend_type"
    t.decimal "amount"
    t.date "ex_date"
    t.date "record_date"
    t.date "payout_date"
    t.string "circular_number"
    t.string "raw_html"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["circular_number"], name: "index_dividend_announcements_on_circular_number", unique: true
    t.index ["company_id"], name: "index_dividend_announcements_on_company_id"
  end

  create_table "price_updates", force: :cascade do |t|
    t.integer "company_id"
    t.datetime "datetime"
    t.decimal "price", precision: 15, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "notes"
    t.index ["company_id"], name: "index_price_updates_on_company_id"
  end

  create_table "stock_dividends", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.bigint "old_id"
    t.bigint "company_id"
    t.integer "amount"
    t.date "pay_date"
    t.date "ex_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.bigint "last_price_update_id"
    t.index ["company_id"], name: "index_stock_dividends_on_company_id"
    t.index ["last_price_update_id"], name: "index_stock_dividends_on_last_price_update_id"
    t.index ["user_id"], name: "index_stock_dividends_on_user_id"
  end

  create_table "users", force: :cascade do |t|
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
  add_foreign_key "dividend_announcements", "companies"
  add_foreign_key "price_updates", "companies"
  add_foreign_key "stock_dividends", "companies"
  add_foreign_key "stock_dividends", "price_updates", column: "last_price_update_id"
  add_foreign_key "stock_dividends", "users"
end
