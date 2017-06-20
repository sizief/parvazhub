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

ActiveRecord::Schema.define(version: 20170620113258) do

  create_table "flight_details", force: :cascade do |t|
    t.integer  "route_id"
    t.string   "call_sign"
    t.datetime "departure_time"
    t.string   "airplane_type"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.string   "status"
    t.integer  "terminal"
    t.datetime "actual_departure_time"
  end

  create_table "flight_price_archives", force: :cascade do |t|
    t.integer  "flight_id"
    t.integer  "price"
    t.string   "supplier"
    t.date     "flight_date"
    t.string   "deep_link"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "flight_prices", force: :cascade do |t|
    t.integer  "flight_id"
    t.integer  "price"
    t.string   "supplier"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.date     "flight_date"
    t.string   "deep_link"
  end

  create_table "flights", force: :cascade do |t|
    t.integer  "route_id"
    t.string   "flight_number"
    t.datetime "departure_time"
    t.string   "airline_code"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.string   "airplane_type"
    t.integer  "best_price"
    t.string   "price_by"
    t.index ["route_id", "flight_number", "departure_time"], name: "index_flights_on_route_id_and_flight_number_and_departure_time", unique: true
  end

  create_table "notifications", force: :cascade do |t|
    t.integer  "route_id"
    t.string   "date"
    t.string   "email"
    t.string   "notification_type"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.boolean  "status"
    t.index ["route_id"], name: "index_notifications_on_route_id"
  end

  create_table "redirects", force: :cascade do |t|
    t.integer  "flight_price_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["flight_price_id"], name: "index_redirects_on_flight_price_id"
  end

  create_table "routes", force: :cascade do |t|
    t.string   "origin"
    t.string   "destination"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "search_histories", force: :cascade do |t|
    t.string   "supplier_name"
    t.integer  "route_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.string   "departure_time"
    t.string   "status"
    t.index ["route_id"], name: "index_search_histories_on_route_id"
  end

  create_table "suppliers", force: :cascade do |t|
    t.string   "name"
    t.string   "class_name"
    t.boolean  "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_search_histories", force: :cascade do |t|
    t.integer  "route_id"
    t.string   "departure_time"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
