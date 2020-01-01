# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_01_01_200220) do

  create_table "activities", force: :cascade do |t|
    t.date "date"
    t.integer "company_id"
    t.string "activity_type"
    t.integer "number_of_shares"
    t.decimal "total_price", precision: 15, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.index ["company_id"], name: "index_cash_dividends_on_company_id"
  end

  create_table "companies", force: :cascade do |t|
    t.string "ticker"
    t.string "industry"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["industry"], name: "index_companies_on_industry"
    t.index ["ticker"], name: "index_companies_on_ticker", unique: true
  end

  create_table "price_updates", force: :cascade do |t|
    t.integer "company_id"
    t.datetime "datetime"
    t.decimal "price", precision: 15, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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

end
