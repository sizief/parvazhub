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

ActiveRecord::Schema.define(version: 2021_06_26_135318) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "airlines", id: :serial, force: :cascade do |t|
    t.string "english_name"
    t.string "persian_name"
    t.string "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "rate_count"
    t.integer "rate_average"
    t.string "country_code"
    t.index ["code"], name: "index_airlines_on_code", unique: true
  end

  create_table "airports", id: :serial, force: :cascade do |t|
    t.string "airport_type"
    t.string "english_name"
    t.string "persian_name"
    t.string "latitude_deg"
    t.string "longitude_deg"
    t.string "elevation_ft"
    t.string "country_code"
    t.string "region_code"
    t.string "city_code"
    t.string "iata_code"
    t.string "home_link"
    t.string "wikipedia_link"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["iata_code"], name: "index_airports_on_iata_code", unique: true
  end

  create_table "cities", id: :serial, force: :cascade do |t|
    t.string "english_name"
    t.string "persian_name"
    t.string "latitude_deg"
    t.string "longitude_deg"
    t.string "country_code"
    t.string "region_code"
    t.string "city_code"
    t.string "home_link"
    t.string "wikipedia_link"
    t.integer "priority"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["city_code"], name: "index_cities_on_city_code", unique: true
    t.index ["english_name"], name: "index_cities_on_english_name"
  end

  create_table "countries", id: :serial, force: :cascade do |t|
    t.string "english_name"
    t.string "persian_name"
    t.string "country_code"
    t.string "continent_code"
    t.string "wikipedia_link"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["country_code"], name: "index_countries_on_country_code", unique: true
  end

  create_table "flight_details", id: :serial, force: :cascade do |t|
    t.integer "route_id"
    t.string "call_sign"
    t.datetime "departure_time"
    t.string "airplane_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status"
    t.integer "terminal"
    t.datetime "actual_departure_time"
    t.index ["call_sign", "departure_time"], name: "index_flight_details_on_call_sign_and_departure_time"
  end

  create_table "flight_infos", id: :serial, force: :cascade do |t|
    t.integer "flight_id"
    t.string "call_sign"
    t.string "airplane"
    t.string "delay"
    t.string "canceled"
    t.string "weekly_delay"
    t.index ["flight_id"], name: "index_flight_infos_on_flight_id"
  end

  create_table "flight_price_archives", id: :serial, force: :cascade do |t|
    t.integer "flight_id"
    t.integer "price"
    t.string "supplier"
    t.date "flight_date"
    t.string "deep_link"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["flight_id", "flight_date"], name: "index_flight_price_archives_on_flight_id_and_flight_date"
  end

  create_table "flight_prices", id: :serial, force: :cascade do |t|
    t.integer "flight_id"
    t.integer "price"
    t.string "supplier"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "flight_date"
    t.string "deep_link"
    t.boolean "is_deep_link_url", default: true
    t.index ["flight_id", "flight_date"], name: "index_flight_prices_on_flight_id_and_flight_date"
  end

  create_table "flights", id: :serial, force: :cascade do |t|
    t.integer "route_id"
    t.string "flight_number"
    t.datetime "departure_time"
    t.string "airline_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "airplane_type"
    t.integer "best_price"
    t.string "price_by"
    t.datetime "arrival_date_time"
    t.integer "trip_duration"
    t.string "stops"
    t.integer "flight_prices_count"
    t.index ["route_id", "flight_number", "departure_time"], name: "index_flights_on_route_id_and_flight_number_and_departure_time", unique: true
  end

  create_table "most_search_routes", id: :serial, force: :cascade do |t|
    t.integer "route_id"
    t.integer "count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["route_id"], name: "index_most_search_routes_on_route_id"
  end

  create_table "notifications", id: :serial, force: :cascade do |t|
    t.integer "route_id"
    t.string "date"
    t.string "email"
    t.string "notification_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "status"
    t.index ["route_id"], name: "index_notifications_on_route_id"
  end

  create_table "proxies", id: :serial, force: :cascade do |t|
    t.string "ip"
    t.integer "port"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "metadata"
    t.boolean "enable", default: true
  end

  create_table "redirects", id: :serial, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "channel"
    t.string "user_agent"
    t.string "remote_ip"
    t.integer "flight_id"
    t.integer "price"
    t.string "supplier"
    t.string "deep_link"
    t.integer "user_id"
    t.index ["supplier"], name: "index_redirects_on_supplier"
    t.index ["user_id"], name: "index_redirects_on_user_id"
  end

  create_table "reviews", id: :serial, force: :cascade do |t|
    t.string "author"
    t.string "page"
    t.text "text"
    t.integer "rate"
    t.integer "reply_to"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.integer "category", default: 0
    t.boolean "published", default: true
    t.index ["user_id"], name: "index_reviews_on_user_id"
  end

  create_table "route_days", id: :serial, force: :cascade do |t|
    t.integer "route_id"
    t.integer "day_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["route_id"], name: "index_route_days_on_route_id"
  end

  create_table "routes", id: :serial, force: :cascade do |t|
    t.string "origin"
    t.string "destination"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "international"
    t.index ["origin", "destination"], name: "index_routes_on_origin_and_destination"
  end

  create_table "search_histories", id: :serial, force: :cascade do |t|
    t.string "supplier_name"
    t.integer "route_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "departure_time"
    t.string "status"
    t.boolean "successful"
    t.index ["created_at", "supplier_name"], name: "index_search_histories_on_created_at_and_supplier_name"
    t.index ["route_id"], name: "index_search_histories_on_route_id"
  end

  create_table "suppliers", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "class_name"
    t.boolean "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "international"
    t.boolean "domestic"
    t.boolean "job_search_allowed"
    t.integer "rate_count"
    t.integer "rate_average"
    t.index ["name"], name: "index_suppliers_on_name", unique: true
  end

  create_table "user_flight_price_histories", id: :serial, force: :cascade do |t|
    t.string "flight_id"
    t.string "channel"
    t.datetime "created_at", default: "2021-06-19 15:56:03", null: false
    t.datetime "updated_at", default: "2021-06-19 15:56:03", null: false
    t.integer "user_id"
    t.index ["user_id"], name: "index_user_flight_price_histories_on_user_id"
  end

  create_table "user_search_histories", id: :serial, force: :cascade do |t|
    t.integer "route_id"
    t.string "departure_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "channel"
    t.integer "user_id"
    t.index ["user_id"], name: "index_user_search_histories_on_user_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "role", default: "basic"
    t.string "first_name"
    t.string "last_name"
    t.string "locale"
    t.string "avatar_url"
    t.string "google_user_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["google_user_id"], name: "index_users_on_google_user_id", unique: true
  end

  add_foreign_key "most_search_routes", "routes"
  add_foreign_key "notifications", "routes"
  add_foreign_key "redirects", "users"
  add_foreign_key "reviews", "users"
  add_foreign_key "route_days", "routes"
  add_foreign_key "search_histories", "routes"
  add_foreign_key "user_flight_price_histories", "users"
  add_foreign_key "user_search_histories", "users"
end
