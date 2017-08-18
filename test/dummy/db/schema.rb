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

ActiveRecord::Schema.define(version: 20170817143457) do

  create_table "oneclick_refernet_categories", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.boolean  "confirmed",  default: false
    t.index ["name"], name: "index_oneclick_refernet_categories_on_name"
  end

  create_table "oneclick_refernet_services", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.boolean  "confirmed",  default: false
    t.text     "details"
    t.index ["name"], name: "index_oneclick_refernet_services_on_name"
  end

  create_table "oneclick_refernet_services_sub_sub_categories", force: :cascade do |t|
    t.integer  "service_id"
    t.integer  "sub_sub_category_id"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.index ["service_id"], name: "idx_svcs_cat_join_table_on_service_id"
    t.index ["sub_sub_category_id"], name: "idx_svcs_cat_join_table_on_sub_sub_category_id"
  end

  create_table "oneclick_refernet_sub_categories", force: :cascade do |t|
    t.string   "name"
    t.integer  "category_id"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.boolean  "confirmed",            default: false
    t.integer  "refernet_category_id"
    t.index ["category_id"], name: "index_oneclick_refernet_sub_categories_on_category_id"
    t.index ["name"], name: "index_oneclick_refernet_sub_categories_on_name"
  end

  create_table "oneclick_refernet_sub_sub_categories", force: :cascade do |t|
    t.string   "name"
    t.integer  "sub_category_id"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.boolean  "confirmed",       default: false
    t.index ["name"], name: "index_oneclick_refernet_sub_sub_categories_on_name"
    t.index ["sub_category_id"], name: "index_oneclick_refernet_sub_sub_categories_on_sub_category_id"
  end

end
