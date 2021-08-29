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

ActiveRecord::Schema.define(version: 2021_08_27_190334) do

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
    t.string "broker_company", null: false
    t.text "notes"
    t.json "other"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

end
