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

ActiveRecord::Schema.define(version: 20210426141815) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "activities", force: :cascade do |t|
    t.string   "name",                 limit: 255
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
    t.index ["activity_category_id"], name: "index_activities_on_activity_category_id", using: :btree
    t.index ["id", "year"], name: "uniq_activities_on_id_and_year", unique: true, using: :btree
    t.index ["year", "leave_time"], name: "index_activities_on_year_and_start", using: :btree
  end

  create_table "activity_categories", force: :cascade do |t|
    t.string  "name",        limit: 25,  null: false
    t.integer "year",                    null: false
    t.string  "description", limit: 500
    t.index ["id", "year"], name: "uniq_activity_categories_on_id_and_year", unique: true, using: :btree
  end

  create_table "attendee_activities", force: :cascade do |t|
    t.integer  "attendee_id", null: false
    t.integer  "activity_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "year",        null: false
    t.index ["activity_id"], name: "index_attendee_activities_on_activity_id", using: :btree
    t.index ["attendee_id", "activity_id"], name: "uniq_attendee_activity", unique: true, using: :btree
  end

  create_table "attendee_plan_dates", force: :cascade do |t|
    t.date    "_date",            null: false
    t.integer "attendee_plan_id"
  end

  create_table "attendee_plans", force: :cascade do |t|
    t.integer  "attendee_id",             null: false
    t.integer  "plan_id",                 null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "quantity",    default: 1, null: false
    t.integer  "year",                    null: false
    t.index ["attendee_id", "plan_id"], name: "uniq_attendee_plan", unique: true, using: :btree
  end

  create_table "attendees", force: :cascade do |t|
    t.string   "given_name",               limit: 255,                 null: false
    t.string   "family_name",              limit: 255,                 null: false
    t.string   "gender",                   limit: 1
    t.boolean  "anonymous"
    t.integer  "rank",                                                 null: false
    t.integer  "aga_id"
    t.string   "country",                  limit: 2
    t.string   "phone",                    limit: 255
    t.string   "email",                    limit: 255
    t.date     "birth_date"
    t.boolean  "understand_minor"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.boolean  "minor_agreement_received",             default: false, null: false
    t.string   "tshirt_size",              limit: 2
    t.text     "special_request"
    t.text     "roomate_request"
    t.string   "comment",                  limit: 255
    t.integer  "year",                                                 null: false
    t.datetime "airport_arrival"
    t.string   "airport_arrival_flight",   limit: 255
    t.datetime "airport_departure"
    t.boolean  "will_play_in_us_open"
    t.integer  "guardian_attendee_id"
    t.integer  "shirt_id"
    t.string   "guardian_full_name",       limit: 255
    t.boolean  "cancelled",                            default: false, null: false
    t.string   "alternate_name",           limit: 255
    t.string   "local_phone",              limit: 255
    t.string   "emergency_name",           limit: 255
    t.string   "emergency_phone",          limit: 255
    t.boolean  "receive_sms"
    t.boolean  "checked_in",                           default: false
    t.string   "state",                    limit: 2
    t.index ["id", "year"], name: "index_attendees_on_id_and_year", unique: true, using: :btree
    t.index ["user_id"], name: "index_attendees_on_user_id", using: :btree
  end

  create_table "bye_appointments", force: :cascade do |t|
    t.integer  "round_id"
    t.integer  "attendee_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["attendee_id"], name: "index_bye_appointments_on_attendee_id", using: :btree
    t.index ["round_id"], name: "index_bye_appointments_on_round_id", using: :btree
  end

  create_table "contacts", force: :cascade do |t|
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

  create_table "content_categories", force: :cascade do |t|
    t.integer  "year",                                         null: false
    t.string   "name",              limit: 50
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "table_of_contents",            default: false
    t.index ["id", "year"], name: "index_content_categories_on_id_and_year", unique: true, using: :btree
  end

  create_table "contents", force: :cascade do |t|
    t.text     "body",                            null: false
    t.string   "subject",             limit: 255, null: false
    t.datetime "expires_at"
    t.boolean  "show_on_homepage",                null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "year",                            null: false
    t.integer  "content_category_id",             null: false
    t.index ["content_category_id"], name: "index_contents_on_content_category_id", using: :btree
    t.index ["year", "show_on_homepage", "expires_at"], name: "index_contents_on_year_and_show_on_homepage_and_expires_at", using: :btree
  end

  create_table "events", force: :cascade do |t|
    t.integer "year",             null: false
    t.string  "name", limit: 255, null: false
    t.index ["id", "year"], name: "index_events_on_id_and_year", unique: true, using: :btree
  end

  create_table "game_appointments", force: :cascade do |t|
    t.string   "location"
    t.datetime "time"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.string   "time_zone"
    t.integer  "year"
    t.integer  "attendee_one_id"
    t.integer  "attendee_two_id"
    t.integer  "round_id"
    t.integer  "table",           null: false
    t.string   "result"
    t.integer  "handicap"
    t.index ["attendee_one_id"], name: "index_game_appointments_on_attendee_one_id", using: :btree
    t.index ["attendee_two_id"], name: "index_game_appointments_on_attendee_two_id", using: :btree
    t.index ["round_id"], name: "index_game_appointments_on_round_id", using: :btree
  end

  create_table "jobs", force: :cascade do |t|
    t.string   "jobname"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "plan_categories", force: :cascade do |t|
    t.string   "name",                 limit: 255,                 null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "year",                                             null: false
    t.string   "description",          limit: 255
    t.integer  "event_id",                                         null: false
    t.boolean  "mandatory",                        default: false, null: false
    t.integer  "ordinal",                          default: 1,     null: false
    t.boolean  "single",                           default: false, null: false
    t.boolean  "show_description",                 default: false, null: false
    t.text     "extended_description"
    t.index ["id", "year"], name: "index_plan_categories_on_id_and_year", unique: true, using: :btree
  end

  create_table "plans", force: :cascade do |t|
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
    t.boolean  "n_a",                             default: false, null: false
    t.index ["id", "year"], name: "index_plans_on_id_and_year", unique: true, using: :btree
    t.index ["plan_category_id"], name: "index_plans_on_plan_category_id", using: :btree
  end

  create_table "rounds", force: :cascade do |t|
    t.integer  "tournament_id"
    t.integer  "number"
    t.datetime "start_time",           null: false
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.integer  "year"
    t.text     "notification_message"
    t.index ["tournament_id"], name: "index_rounds_on_tournament_id", using: :btree
  end

  create_table "shirts", force: :cascade do |t|
    t.integer  "year",                                    null: false
    t.string   "name",        limit: 40,                  null: false
    t.string   "hex_triplet", limit: 6,                   null: false
    t.string   "description", limit: 100,                 null: false
    t.string   "image_url",   limit: 250
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.boolean  "disabled",                default: false, null: false
    t.index ["hex_triplet", "year"], name: "index_shirts_on_hex_triplet_and_year", unique: true, using: :btree
    t.index ["id", "year"], name: "index_shirts_on_id_and_year", unique: true, using: :btree
    t.index ["name", "year"], name: "index_shirts_on_name_and_year", unique: true, using: :btree
  end

  create_table "sms_notifications", force: :cascade do |t|
    t.string   "to"
    t.string   "from"
    t.text     "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tournaments", force: :cascade do |t|
    t.string   "name",             limit: 50,                  null: false
    t.string   "eligible",         limit: 255,                 null: false
    t.text     "description",                                  null: false
    t.string   "directors",        limit: 255,                 null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "openness",         limit: 1,   default: "O",   null: false
    t.integer  "year",                                         null: false
    t.string   "location",         limit: 50
    t.boolean  "show_in_nav_menu",             default: false, null: false
    t.integer  "ordinal",                      default: 1,     null: false
    t.index ["id", "year"], name: "index_tournaments_on_id_and_year", unique: true, using: :btree
  end

  create_table "transactions", force: :cascade do |t|
    t.integer  "user_id",                        null: false
    t.string   "trantype",           limit: 1,   null: false
    t.string   "gwtranid"
    t.date     "gwdate"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "check_number"
    t.integer  "updated_by_user_id"
    t.string   "comment",            limit: 255
    t.string   "instrument",         limit: 1
    t.integer  "year",                           null: false
    t.integer  "amount",                         null: false
    t.string   "receipt_url"
    t.index ["user_id"], name: "index_transactions_on_user_id", using: :btree
    t.index ["year", "created_at"], name: "index_transactions_on_year_and_created_at", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "",  null: false
    t.string   "encrypted_password",     limit: 128, default: "",  null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "role",                   limit: 1,   default: "U", null: false
    t.integer  "year",                                             null: false
    t.datetime "reset_password_sent_at"
    t.index ["email", "year"], name: "index_users_on_email_and_year", unique: true, using: :btree
    t.index ["id", "year"], name: "index_users_on_id_and_year", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
    t.index ["year"], name: "index_users_on_year", using: :btree
  end

  create_table "years", force: :cascade do |t|
    t.string  "city",               limit: 255
    t.string  "date_range",         limit: 255,             null: false
    t.date    "day_off_date",                               null: false
    t.integer "ordinal_number",                             null: false
    t.string  "registration_phase", limit: 255,             null: false
    t.string  "reply_to_email",     limit: 255,             null: false
    t.date    "start_date",                                 null: false
    t.string  "state",              limit: 255
    t.string  "timezone",           limit: 255,             null: false
    t.string  "twitter_url",        limit: 255
    t.integer "year",                                       null: false
    t.string  "venue_url",          limit: 255
    t.string  "venue_name",         limit: 255
    t.string  "venue_address",      limit: 255
    t.string  "venue_city",         limit: 255
    t.string  "venue_state",        limit: 2
    t.string  "venue_zip",          limit: 10
    t.string  "venue_phone",        limit: 20
    t.text    "refund_policy"
    t.integer "event_type",                     default: 0
    t.index ["year"], name: "index_years_on_year", unique: true, using: :btree
  end

  add_foreign_key "activities", "activity_categories", name: "fk_events_event_category_id_year", on_update: :cascade, on_delete: :cascade
  add_foreign_key "attendee_activities", "activities", name: "fk_attendee_events_event_id_year", on_update: :cascade, on_delete: :cascade
  add_foreign_key "attendee_activities", "attendees", name: "fk_attendee_events_attendee_id_year", on_update: :cascade, on_delete: :cascade
  add_foreign_key "attendee_plan_dates", "attendee_plans", name: "fk_attendee_plan_dates_attendee_plan_id", on_update: :cascade, on_delete: :cascade
  add_foreign_key "attendee_plans", "attendees", name: "fk_attendee_plans_attendee_id_year", on_update: :cascade, on_delete: :cascade
  add_foreign_key "attendee_plans", "plans", name: "fk_attendee_plans_plan_id_year", on_update: :cascade, on_delete: :restrict
  add_foreign_key "attendees", "attendees", column: "guardian_attendee_id", name: "fk_attendees_guardian_attendee_id_year", on_update: :cascade, on_delete: :restrict
  add_foreign_key "attendees", "shirts", name: "fk_attendees_shirt_id_year", on_update: :cascade, on_delete: :restrict
  add_foreign_key "attendees", "users", name: "fk_attendees_user_id_year", on_update: :cascade, on_delete: :cascade
  add_foreign_key "bye_appointments", "attendees"
  add_foreign_key "bye_appointments", "rounds"
  add_foreign_key "contacts", "years", column: "year", primary_key: "year", name: "fk_contacts_year", on_update: :cascade, on_delete: :cascade
  add_foreign_key "contents", "content_categories", name: "fk_contents_content_category_id_year", on_update: :cascade, on_delete: :cascade
  add_foreign_key "game_appointments", "attendees", column: "attendee_one_id"
  add_foreign_key "game_appointments", "attendees", column: "attendee_two_id"
  add_foreign_key "game_appointments", "rounds"
  add_foreign_key "plan_categories", "events", name: "fk_plan_categories_event_id_year", on_update: :cascade, on_delete: :cascade
  add_foreign_key "plans", "plan_categories", name: "fk_plans_plan_category_id_year", on_update: :cascade, on_delete: :cascade
  add_foreign_key "rounds", "tournaments"
  add_foreign_key "transactions", "users", column: "updated_by_user_id", name: "fk_transactions_updated_by_user_id_year", on_update: :cascade, on_delete: :nullify
  add_foreign_key "transactions", "users", name: "fk_transactions_user_id_year", on_update: :cascade, on_delete: :restrict
end
