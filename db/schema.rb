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

ActiveRecord::Schema.define(version: 2021_08_31_133120) do

  create_table "broker_companies", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "broker_company_identifiers", force: :cascade do |t|
    t.string "identifier"
    t.integer "broker_company_id", null: false
    t.integer "load_board_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["broker_company_id"], name: "index_broker_company_identifiers_on_broker_company_id"
    t.index ["load_board_id"], name: "index_broker_company_identifiers_on_load_board_id"
  end

  create_table "cities", force: :cascade do |t|
    t.string "city", null: false
    t.string "state", limit: 2, null: false
    t.integer "radius", null: false
    t.integer "tql_id"
    t.float "latitude", null: false
    t.float "longitude", null: false
    t.string "county", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "coordinates", force: :cascade do |t|
    t.float "latitude"
    t.float "longitude"
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "load_boards", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "load_identifiers", force: :cascade do |t|
    t.string "identifier"
    t.integer "load_board_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "deleted_at"
    t.index ["load_board_id"], name: "index_load_identifiers_on_load_board_id"
  end

  create_table "loads", force: :cascade do |t|
    t.integer "weight", null: false
    t.integer "length"
    t.integer "distance", null: false
    t.integer "rate"
    t.string "contact_name"
    t.string "contact_phone"
    t.string "contact_email"
    t.string "reference_number"
    t.datetime "pickup_date", null: false
    t.datetime "dropoff_date"
    t.json "pickup_location", null: false
    t.json "dropoff_location", null: false
    t.string "commodity"
    t.text "notes"
    t.json "raw"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "broker_company_id", null: false
    t.integer "load_identifier_id", null: false
    t.datetime "dismissed_at"
    t.string "equipment_type"
    t.string "equipment_type_code"
    t.string "pickup_details"
    t.string "dropoff_details"
    t.index ["broker_company_id"], name: "index_loads_on_broker_company_id"
    t.index ["load_identifier_id"], name: "index_loads_on_load_identifier_id"
  end

  create_table "places_distances", force: :cascade do |t|
    t.string "origin", null: false
    t.string "destination", null: false
    t.integer "distance", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["origin", "destination"], name: "index_places_distances_on_origin_and_destination", unique: true
  end

  create_table "raw_loads", force: :cascade do |t|
    t.json "data"
    t.integer "load_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["load_id"], name: "index_raw_loads_on_load_id"
  end

  add_foreign_key "broker_company_identifiers", "broker_companies"
  add_foreign_key "broker_company_identifiers", "load_boards"
  add_foreign_key "load_identifiers", "load_boards"
  add_foreign_key "loads", "broker_companies"
  add_foreign_key "loads", "load_identifiers", on_delete: :cascade
  add_foreign_key "raw_loads", "loads"
end
