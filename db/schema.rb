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

ActiveRecord::Schema.define(version: 20180406081057) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "airlines", force: :cascade do |t|
    t.string   "english_name"
    t.string   "persian_name"
    t.string   "code"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "rate_count"
    t.integer  "rate_average"
    t.string   "country_code"
    t.index ["code"], name: "index_airlines_on_code", unique: true, using: :btree
  end

  create_table "airports", force: :cascade do |t|
    t.string   "airport_type"
    t.string   "english_name"
    t.string   "persian_name"
    t.string   "latitude_deg"
    t.string   "longitude_deg"
    t.string   "elevation_ft"
    t.string   "country_code"
    t.string   "region_code"
    t.string   "city_code"
    t.string   "iata_code"
    t.string   "home_link"
    t.string   "wikipedia_link"
    t.string   "status"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.index ["iata_code"], name: "index_airports_on_iata_code", unique: true, using: :btree
  end

  create_table "cities", force: :cascade do |t|
    t.string   "english_name"
    t.string   "persian_name"
    t.string   "latitude_deg"
    t.string   "longitude_deg"
    t.string   "country_code"
    t.string   "region_code"
    t.string   "city_code"
    t.string   "home_link"
    t.string   "wikipedia_link"
    t.integer  "priority"
    t.string   "status"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.index ["city_code"], name: "index_cities_on_city_code", unique: true, using: :btree
    t.index ["english_name"], name: "index_cities_on_english_name", using: :btree
  end

  create_table "countries", force: :cascade do |t|
    t.string   "english_name"
    t.string   "persian_name"
    t.string   "country_code"
    t.string   "continent_code"
    t.string   "wikipedia_link"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.index ["country_code"], name: "index_countries_on_country_code", unique: true, using: :btree
  end

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
    t.index ["call_sign", "departure_time"], name: "index_flight_details_on_call_sign_and_departure_time", using: :btree
  end

  create_table "flight_infos", force: :cascade do |t|
    t.integer "flight_id"
    t.string  "call_sign"
    t.string  "airplane"
    t.string  "delay"
    t.string  "canceled"
    t.string  "weekly_delay"
    t.index ["flight_id"], name: "index_flight_infos_on_flight_id", using: :btree
  end

  create_table "flight_price_archives", force: :cascade do |t|
    t.integer  "flight_id"
    t.integer  "price"
    t.string   "supplier"
    t.date     "flight_date"
    t.string   "deep_link"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["flight_id", "flight_date"], name: "index_flight_price_archives_on_flight_id_and_flight_date", using: :btree
  end

  create_table "flight_prices", force: :cascade do |t|
    t.integer  "flight_id"
    t.integer  "price"
    t.string   "supplier"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.date     "flight_date"
    t.string   "deep_link"
    t.boolean  "is_deep_link_url", default: true
    t.index ["flight_id", "flight_date"], name: "index_flight_prices_on_flight_id_and_flight_date", using: :btree
  end

  create_table "flights", force: :cascade do |t|
    t.integer  "route_id"
    t.string   "flight_number"
    t.datetime "departure_time"
    t.string   "airline_code"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.string   "airplane_type"
    t.integer  "best_price"
    t.string   "price_by"
    t.datetime "arrival_date_time"
    t.integer  "trip_duration"
    t.string   "stops"
    t.integer  "flight_prices_count"
    t.index ["route_id", "flight_number", "departure_time"], name: "index_flights_on_route_id_and_flight_number_and_departure_time", unique: true, using: :btree
  end

  create_table "hotels", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "most_search_routes", force: :cascade do |t|
    t.integer  "route_id"
    t.integer  "count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["route_id"], name: "index_most_search_routes_on_route_id", using: :btree
  end

  create_table "notifications", force: :cascade do |t|
    t.integer  "route_id"
    t.string   "date"
    t.string   "email"
    t.string   "notification_type"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.boolean  "status"
    t.index ["route_id"], name: "index_notifications_on_route_id", using: :btree
  end

  create_table "proxies", force: :cascade do |t|
    t.string   "ip"
    t.integer  "port"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "status"
  end

  create_table "redirects", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "channel"
    t.string   "user_agent"
    t.string   "remote_ip"
    t.integer  "flight_id"
    t.integer  "price"
    t.string   "supplier"
    t.string   "deep_link"
    t.integer  "user_id"
    t.index ["supplier"], name: "index_redirects_on_supplier", using: :btree
    t.index ["user_id"], name: "index_redirects_on_user_id", using: :btree
  end

  create_table "reviews", force: :cascade do |t|
    t.string   "author"
    t.string   "page"
    t.text     "text"
    t.integer  "rate"
    t.string   "status"
    t.integer  "reply_to"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "user_id"
    t.integer  "category",   default: 0
    t.index ["user_id"], name: "index_reviews_on_user_id", using: :btree
  end

  create_table "route_days", force: :cascade do |t|
    t.integer  "route_id"
    t.integer  "day_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["route_id"], name: "index_route_days_on_route_id", using: :btree
  end

  create_table "routes", force: :cascade do |t|
    t.string   "origin"
    t.string   "destination"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.boolean  "international"
    t.index ["origin", "destination"], name: "index_routes_on_origin_and_destination", using: :btree
  end

  create_table "search_flight_ids", force: :cascade do |t|
    t.text   "flight_ids"
    t.string "token"
  end

  create_table "search_histories", force: :cascade do |t|
    t.string   "supplier_name"
    t.integer  "route_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.string   "departure_time"
    t.string   "status"
    t.boolean  "successful"
    t.index ["created_at", "supplier_name"], name: "index_search_histories_on_created_at_and_supplier_name", using: :btree
    t.index ["route_id"], name: "index_search_histories_on_route_id", using: :btree
  end

  create_table "suppliers", force: :cascade do |t|
    t.string   "name"
    t.string   "class_name"
    t.boolean  "status"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.boolean  "international"
    t.boolean  "domestic"
    t.boolean  "job_search_allowed"
    t.integer  "rate_count"
    t.integer  "rate_average"
  end

  create_table "telegram_search_queries", force: :cascade do |t|
    t.string  "origin"
    t.string  "destination"
    t.string  "date"
    t.string  "flight_price"
    t.string  "chat_id"
    t.integer "user_id"
    t.index ["user_id"], name: "index_telegram_search_queries_on_user_id", using: :btree
  end

  create_table "telegram_update_ids", force: :cascade do |t|
    t.string "update_id"
  end

  create_table "temp_airports", force: :cascade do |t|
    t.string "ident"
    t.string "type_airport"
    t.string "name"
    t.string "latitude_deg"
    t.string "longitude_deg"
    t.string "elevation_ft"
    t.string "continent"
    t.string "iso_country"
    t.string "iso_region"
    t.string "municipality"
    t.string "scheduled_service"
    t.string "gps_code"
    t.string "iata_code"
    t.string "local_code"
    t.string "home_link"
    t.string "wikipedia_link"
    t.string "keywords"
  end

  create_table "user_flight_price_histories", force: :cascade do |t|
    t.string   "flight_id"
    t.string   "channel"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "user_id"
    t.index ["user_id"], name: "index_user_flight_price_histories_on_user_id", using: :btree
  end

  create_table "user_search_histories", force: :cascade do |t|
    t.integer  "route_id"
    t.string   "departure_time"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.string   "channel"
    t.integer  "user_id"
    t.index ["user_id"], name: "index_user_search_histories_on_user_id", using: :btree
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
    t.string   "telegram_id"
    t.integer  "role"
    t.string   "first_name"
    t.string   "last_name"
    t.integer  "channel"
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  add_foreign_key "most_search_routes", "routes"
  add_foreign_key "notifications", "routes"
  add_foreign_key "redirects", "users"
  add_foreign_key "reviews", "users"
  add_foreign_key "route_days", "routes"
  add_foreign_key "search_histories", "routes"
  add_foreign_key "telegram_search_queries", "users"
  add_foreign_key "user_flight_price_histories", "users"
  add_foreign_key "user_search_histories", "users"
end
