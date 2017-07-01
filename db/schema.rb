# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20170628090033) do

  create_table "accounts", force: :cascade do |t|
    t.string   "name",         limit: 255
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.string   "type",         limit: 255
    t.integer  "actable_id",   limit: 4
    t.string   "actable_type", limit: 255
  end

  create_table "attendances", force: :cascade do |t|
    t.date     "date"
    t.integer  "scout_id",   limit: 4
    t.boolean  "attending",  limit: 1
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "attendances", ["scout_id"], name: "index_attendances_on_scout_id", using: :btree

  create_table "bookings", force: :cascade do |t|
    t.date     "date"
    t.integer  "account_id",        limit: 4
    t.decimal  "amount",                        precision: 10
    t.string   "note1",             limit: 255
    t.string   "note2",             limit: 255
    t.string   "remarks",           limit: 255
    t.integer  "accounting_number", limit: 4
    t.integer  "created_by_id",     limit: 4
    t.integer  "updated_by_id",     limit: 4
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.integer  "root_booking_id",   limit: 4
  end

  add_index "bookings", ["account_id"], name: "index_bookings_on_account_id", using: :btree
  add_index "bookings", ["root_booking_id"], name: "index_bookings_on_root_booking_id", using: :btree

  create_table "child_accounts", force: :cascade do |t|
    t.integer  "child_id",   limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "child_accounts", ["child_id"], name: "index_child_accounts_on_child_id", using: :btree

  create_table "child_consumptions", force: :cascade do |t|
    t.integer  "child_id",    limit: 4
    t.date     "date"
    t.string   "time_of_day", limit: 255
    t.integer  "soft_drink",  limit: 4
    t.decimal  "other",                   precision: 10
    t.string   "created_by",  limit: 255
    t.string   "edited_by",   limit: 255
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  add_index "child_consumptions", ["child_id"], name: "index_child_consumptions_on_child_id", using: :btree

  create_table "children", force: :cascade do |t|
    t.string   "first_name", limit: 255
    t.string   "last_name",  limit: 255
    t.date     "birthday"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.integer  "tent_id",    limit: 4
    t.string   "phone",      limit: 255
    t.binary   "image",      limit: 65535
    t.integer  "source_id",  limit: 4
    t.integer  "number",     limit: 4
  end

  add_index "children", ["tent_id"], name: "index_children_on_tent_id", using: :btree

  create_table "disbursements", force: :cascade do |t|
    t.date     "date"
    t.integer  "account_id", limit: 4
    t.boolean  "cleared",    limit: 1
    t.decimal  "amount",                 precision: 10, scale: 2
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.integer  "user_id",    limit: 4
    t.string   "note",       limit: 255
  end

  add_index "disbursements", ["account_id"], name: "index_disbursements_on_account_id", using: :btree
  add_index "disbursements", ["user_id"], name: "index_disbursements_on_user_id", using: :btree

  create_table "goods", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.decimal  "price",                  precision: 10, scale: 2
    t.date     "date"
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.string   "type",       limit: 255
  end

  create_table "main_accounts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "news", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.text     "comment",    limit: 16777215
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "news", ["user_id"], name: "index_news_on_user_id", using: :btree

  create_table "scout_accounts", force: :cascade do |t|
    t.integer  "scout_id",   limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "scout_accounts", ["scout_id"], name: "index_scout_accounts_on_scout_id", using: :btree

  create_table "scout_consumptions", force: :cascade do |t|
    t.date     "date"
    t.integer  "scout_id",   limit: 4
    t.integer  "beer",       limit: 4
    t.integer  "soft_drink", limit: 4
    t.integer  "sausage",    limit: 4
    t.integer  "pork",       limit: 4
    t.integer  "turkey",     limit: 4
    t.decimal  "other",                  precision: 10, scale: 2
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.string   "created_by", limit: 255
    t.string   "edited_by",  limit: 255
    t.string   "notes",      limit: 255
    t.integer  "corn",       limit: 4
  end

  add_index "scout_consumptions", ["scout_id"], name: "index_scout_consumptions_on_scout_id", using: :btree

  create_table "scouts", force: :cascade do |t|
    t.string   "first_name", limit: 255
    t.string   "last_name",  limit: 255
    t.date     "birthday"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "tent_id",    limit: 4
  end

  add_index "scouts", ["tent_id"], name: "index_scouts_on_tent_id", using: :btree

  create_table "settings", force: :cascade do |t|
    t.string   "key",        limit: 255
    t.string   "value",      limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.string   "type",       limit: 255
  end

  create_table "tents", force: :cascade do |t|
    t.integer  "number",     limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.string   "name",       limit: 255
    t.integer  "source_id",  limit: 4
  end

  create_table "users", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_foreign_key "attendances", "scouts"
end
