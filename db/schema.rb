# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_04_30_180240) do

  # These are extensions that must be enabled in order to support this database
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
    t.index ["activity_type"], name: "index_activities_on_activity_type"
    t.index ["company_id"], name: "index_activities_on_company_id"
  end

  create_table "cash_dividends", force: :cascade do |t|
    t.integer "company_id"
    t.decimal "amount", precision: 15, scale: 2
    t.date "pay_date"
    t.date "ex_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "meta"
    t.bigint "user_id"
    t.index ["company_id"], name: "index_cash_dividends_on_company_id"
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
    t.index ["industry"], name: "index_companies_on_industry"
    t.index ["ticker"], name: "index_companies_on_ticker", unique: true
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

  create_table "stock_dividends", force: :cascade do |t|
    t.integer "company_id"
    t.integer "amount"
    t.date "pay_date"
    t.date "ex_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_stock_dividends_on_company_id"
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
  add_foreign_key "cash_dividends", "companies"
  add_foreign_key "cash_dividends", "users"
  add_foreign_key "price_updates", "companies"
  add_foreign_key "stock_dividends", "companies"
end
