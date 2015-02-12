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

ActiveRecord::Schema.define(version: 20150211232505) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "activities", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "leave_time"
    t.string   "notes",                limit: 2000
    t.time     "return_time"
    t.integer  "year",                                              null: false
    t.string   "location",             limit: 50
    t.integer  "activity_category_id",                              null: false
    t.boolean  "price_varies",                      default: false, null: false
    t.boolean  "disabled",                          default: false, null: false
    t.integer  "price",                                             null: false
    t.string   "phone",                limit: 20
    t.string   "url",                  limit: 200
  end

  add_index "activities", ["activity_category_id"], name: "index_activities_on_activity_category_id", using: :btree
  add_index "activities", ["id", "year"], name: "uniq_activities_on_id_and_year", unique: true, using: :btree
  add_index "activities", ["year", "leave_time"], name: "index_activities_on_year_and_start", using: :btree

  create_table "activity_categories", force: true do |t|
    t.string  "name",        limit: 25,  null: false
    t.integer "year",                    null: false
    t.string  "description", limit: 500
  end

  add_index "activity_categories", ["id", "year"], name: "uniq_activity_categories_on_id_and_year", unique: true, using: :btree

  create_table "attendee_activities", force: true do |t|
    t.integer  "attendee_id", null: false
    t.integer  "activity_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "year",        null: false
  end

  add_index "attendee_activities", ["activity_id"], name: "index_attendee_activities_on_activity_id", using: :btree
  add_index "attendee_activities", ["attendee_id", "activity_id"], name: "uniq_attendee_activity", unique: true, using: :btree

  create_table "attendee_plan_dates", force: true do |t|
    t.date    "_date",            null: false
    t.integer "attendee_plan_id"
  end

  create_table "attendee_plans", force: true do |t|
    t.integer  "attendee_id",             null: false
    t.integer  "plan_id",                 null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "quantity",    default: 1, null: false
    t.integer  "year",                    null: false
  end

  add_index "attendee_plans", ["attendee_id", "plan_id"], name: "uniq_attendee_plan", unique: true, using: :btree

  create_table "attendees", force: true do |t|
    t.string   "given_name",                                         null: false
    t.string   "family_name",                                        null: false
    t.string   "gender",                   limit: 1
    t.boolean  "anonymous"
    t.integer  "rank",                                               null: false
    t.integer  "aga_id"
    t.string   "country",                  limit: 2
    t.string   "phone"
    t.string   "email"
    t.date     "birth_date"
    t.boolean  "understand_minor"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.boolean  "minor_agreement_received",           default: false, null: false
    t.string   "tshirt_size",              limit: 2
    t.text     "special_request"
    t.text     "roomate_request"
    t.string   "comment"
    t.integer  "year",                                               null: false
    t.datetime "airport_arrival"
    t.string   "airport_arrival_flight"
    t.datetime "airport_departure"
    t.boolean  "will_play_in_us_open"
    t.integer  "guardian_attendee_id"
    t.integer  "shirt_id"
    t.string   "guardian_full_name"
    t.boolean  "cancelled",                          default: false, null: false
  end

  add_index "attendees", ["aga_id", "year"], name: "index_attendees_on_aga_id_and_year", unique: true, using: :btree
  add_index "attendees", ["id", "year"], name: "index_attendees_on_id_and_year", unique: true, using: :btree
  add_index "attendees", ["user_id"], name: "index_attendees_on_user_id", using: :btree

  create_table "contacts", force: true do |t|
    t.integer  "year",                    null: false
    t.string   "title",       limit: 50,  null: false
    t.string   "given_name",  limit: 50,  null: false
    t.string   "family_name", limit: 50,  null: false
    t.string   "email",       limit: 100
    t.string   "phone",       limit: 20
    t.integer  "list_order"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "content_categories", force: true do |t|
    t.integer  "year",                  null: false
    t.string   "name",       limit: 50
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "content_categories", ["id", "year"], name: "index_content_categories_on_id_and_year", unique: true, using: :btree

  create_table "contents", force: true do |t|
    t.text     "body",                null: false
    t.string   "subject",             null: false
    t.datetime "expires_at"
    t.boolean  "show_on_homepage",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "year",                null: false
    t.integer  "content_category_id", null: false
  end

  add_index "contents", ["content_category_id"], name: "index_contents_on_content_category_id", using: :btree
  add_index "contents", ["year", "show_on_homepage", "expires_at"], name: "index_contents_on_year_and_show_on_homepage_and_expires_at", using: :btree

  create_table "events", force: true do |t|
    t.integer "year", null: false
    t.string  "name", null: false
  end

  add_index "events", ["id", "year"], name: "index_events_on_id_and_year", unique: true, using: :btree

  create_table "plan_categories", force: true do |t|
    t.string   "name",                        null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "year",                        null: false
    t.string   "description"
    t.integer  "event_id",                    null: false
    t.boolean  "mandatory",   default: false, null: false
    t.integer  "ordinal",     default: 1,     null: false
  end

  add_index "plan_categories", ["id", "year"], name: "index_plan_categories_on_id_and_year", unique: true, using: :btree

  create_table "plans", force: true do |t|
    t.string   "name",                 limit: 50,                 null: false
    t.integer  "age_min",                                         null: false
    t.integer  "age_max"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
    t.integer  "plan_category_id",                                null: false
    t.integer  "max_quantity",                    default: 1,     null: false
    t.integer  "year",                                            null: false
    t.integer  "inventory"
    t.boolean  "needs_staff_approval",            default: false, null: false
    t.integer  "cat_order",                       default: 0,     null: false
    t.boolean  "disabled",                        default: false, null: false
    t.integer  "price",                                           null: false
    t.boolean  "daily",                           default: false, null: false
    t.boolean  "show_disabled",                   default: false, null: false
  end

  add_index "plans", ["id", "year"], name: "index_plans_on_id_and_year", unique: true, using: :btree
  add_index "plans", ["plan_category_id"], name: "index_plans_on_plan_category_id", using: :btree

  create_table "shirts", force: true do |t|
    t.integer  "year",                                    null: false
    t.string   "name",        limit: 40,                  null: false
    t.string   "hex_triplet", limit: 6,                   null: false
    t.string   "description", limit: 100,                 null: false
    t.string   "image_url",   limit: 250
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.boolean  "disabled",                default: false, null: false
  end

  add_index "shirts", ["hex_triplet", "year"], name: "index_shirts_on_hex_triplet_and_year", unique: true, using: :btree
  add_index "shirts", ["id", "year"], name: "index_shirts_on_id_and_year", unique: true, using: :btree
  add_index "shirts", ["name", "year"], name: "index_shirts_on_name_and_year", unique: true, using: :btree

  create_table "tournaments", force: true do |t|
    t.string   "name",             limit: 50,                 null: false
    t.string   "eligible",                                    null: false
    t.text     "description",                                 null: false
    t.string   "directors",                                   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "openness",         limit: 1,  default: "O",   null: false
    t.integer  "year",                                        null: false
    t.string   "location",         limit: 50
    t.boolean  "show_in_nav_menu",            default: false, null: false
  end

  add_index "tournaments", ["id", "year"], name: "index_tournaments_on_id_and_year", unique: true, using: :btree

  create_table "transactions", force: true do |t|
    t.integer  "user_id",                      null: false
    t.string   "trantype",           limit: 1, null: false
    t.integer  "gwtranid",           limit: 8
    t.date     "gwdate"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "check_number"
    t.integer  "updated_by_user_id"
    t.string   "comment"
    t.string   "instrument",         limit: 1
    t.integer  "year",                         null: false
    t.integer  "amount",                       null: false
  end

  add_index "transactions", ["user_id"], name: "index_transactions_on_user_id", using: :btree
  add_index "transactions", ["year", "created_at"], name: "index_transactions_on_year_and_created_at", using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                              default: "",  null: false
    t.string   "encrypted_password",     limit: 128, default: "",  null: false
    t.string   "reset_password_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "role",                   limit: 1,   default: "U", null: false
    t.integer  "year",                                             null: false
    t.datetime "reset_password_sent_at"
  end

  add_index "users", ["email", "year"], name: "index_users_on_email_and_year", unique: true, using: :btree
  add_index "users", ["id", "year"], name: "index_users_on_id_and_year", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["year"], name: "index_users_on_year", using: :btree

  create_table "years", force: true do |t|
    t.string  "city",                          null: false
    t.string  "date_range",                    null: false
    t.date    "day_off_date",                  null: false
    t.integer "ordinal_number",                null: false
    t.string  "registration_phase",            null: false
    t.string  "reply_to_email",                null: false
    t.date    "start_date",                    null: false
    t.string  "state",                         null: false
    t.string  "timezone",                      null: false
    t.string  "twitter_url"
    t.integer "year",                          null: false
    t.string  "venue_url"
    t.string  "venue_name"
    t.string  "venue_address"
    t.string  "venue_city"
    t.string  "venue_state",        limit: 2
    t.string  "venue_zip",          limit: 10
    t.string  "venue_phone",        limit: 20
  end

  add_index "years", ["year"], name: "index_years_on_year", unique: true, using: :btree

end
