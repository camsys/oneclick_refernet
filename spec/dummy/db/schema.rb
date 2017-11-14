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

ActiveRecord::Schema.define(version: 20171114162806) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "postgis"

  create_table "locales", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "oneclick_refernet_categories", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.boolean  "confirmed",    default: false
    t.integer  "sequence_nbr"
    t.string   "code"
    t.index ["name"], name: "index_oneclick_refernet_categories_on_name", using: :btree
  end

  create_table "oneclick_refernet_services", force: :cascade do |t|
    t.datetime "created_at",                                                           null: false
    t.datetime "updated_at",                                                           null: false
    t.boolean  "confirmed",                                            default: false
    t.text     "details"
    t.geometry "latlng",      limit: {:srid=>4326, :type=>"st_point"}
    t.string   "agency_name"
    t.string   "site_name"
    t.text     "description"
    t.index ["latlng"], name: "index_oneclick_refernet_services_on_latlng", using: :gist
  end

  create_table "oneclick_refernet_services_sub_sub_categories", force: :cascade do |t|
    t.integer  "service_id"
    t.integer  "sub_sub_category_id"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.index ["service_id"], name: "idx_svcs_cat_join_table_on_service_id", using: :btree
    t.index ["sub_sub_category_id"], name: "idx_svcs_cat_join_table_on_sub_sub_category_id", using: :btree
  end

  create_table "oneclick_refernet_sub_categories", force: :cascade do |t|
    t.string   "name"
    t.integer  "category_id"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.boolean  "confirmed",            default: false
    t.integer  "refernet_category_id"
    t.string   "code"
    t.index ["category_id"], name: "index_oneclick_refernet_sub_categories_on_category_id", using: :btree
    t.index ["name"], name: "index_oneclick_refernet_sub_categories_on_name", using: :btree
  end

  create_table "oneclick_refernet_sub_sub_categories", force: :cascade do |t|
    t.string   "name"
    t.integer  "sub_category_id"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.boolean  "confirmed",       default: false
    t.string   "code"
    t.index ["name"], name: "index_oneclick_refernet_sub_sub_categories_on_name", using: :btree
    t.index ["sub_category_id"], name: "index_oneclick_refernet_sub_sub_categories_on_sub_category_id", using: :btree
  end

  create_table "oneclick_refernet_translations", force: :cascade do |t|
    t.string   "key"
    t.string   "locale"
    t.text     "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_oneclick_refernet_translations_on_key", using: :btree
  end

  create_table "translation_keys", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "translations", force: :cascade do |t|
    t.integer  "locale_id"
    t.integer  "translation_key_id"
    t.text     "value"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  add_foreign_key "oneclick_refernet_services_sub_sub_categories", "oneclick_refernet_services", column: "service_id"
  add_foreign_key "oneclick_refernet_services_sub_sub_categories", "oneclick_refernet_sub_sub_categories", column: "sub_sub_category_id"
  add_foreign_key "oneclick_refernet_sub_categories", "oneclick_refernet_categories", column: "category_id"
  add_foreign_key "oneclick_refernet_sub_sub_categories", "oneclick_refernet_sub_categories", column: "sub_category_id"
end
