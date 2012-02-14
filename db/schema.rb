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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120214030844) do

  create_table "activities", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "leave_time"
    t.string   "notes",                :limit => 250
    t.time     "return_time"
    t.integer  "year",                                                               :null => false
    t.string   "location",             :limit => 50
    t.integer  "activity_category_id",                                               :null => false
    t.decimal  "price",                               :precision => 10, :scale => 2, :null => false
  end

  add_index "activities", ["activity_category_id"], :name => "index_activities_on_activity_category_id"
  add_index "activities", ["id", "year"], :name => "uniq_activities_on_id_and_year", :unique => true
  add_index "activities", ["year", "leave_time"], :name => "index_activities_on_year_and_start"

  create_table "activity_categories", :force => true do |t|
    t.string  "name", :limit => 25, :null => false
    t.integer "year",               :null => false
  end

  add_index "activity_categories", ["id", "year"], :name => "uniq_activity_categories_on_id_and_year", :unique => true

  create_table "attendee_activities", :force => true do |t|
    t.integer  "attendee_id", :null => false
    t.integer  "activity_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "year",        :null => false
  end

  add_index "attendee_activities", ["activity_id"], :name => "index_attendee_activities_on_activity_id"
  add_index "attendee_activities", ["attendee_id", "activity_id"], :name => "uniq_attendee_activity", :unique => true

  create_table "attendee_discounts", :force => true do |t|
    t.integer  "attendee_id", :null => false
    t.integer  "discount_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "year",        :null => false
  end

  add_index "attendee_discounts", ["attendee_id", "discount_id"], :name => "uniq_attendee_discount", :unique => true
  add_index "attendee_discounts", ["discount_id"], :name => "index_attendee_discounts_on_discount_id"

  create_table "attendee_plans", :force => true do |t|
    t.integer  "attendee_id",                :null => false
    t.integer  "plan_id",                    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "quantity",    :default => 1, :null => false
    t.integer  "year",                       :null => false
  end

  add_index "attendee_plans", ["attendee_id", "plan_id"], :name => "uniq_attendee_plan", :unique => true

  create_table "attendee_tournaments", :force => true do |t|
    t.integer  "attendee_id",   :null => false
    t.integer  "tournament_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "notes"
    t.integer  "year",          :null => false
  end

  add_index "attendee_tournaments", ["attendee_id", "tournament_id"], :name => "uniq_attendee_tournament", :unique => true
  add_index "attendee_tournaments", ["tournament_id"], :name => "index_attendee_tournaments_on_tournament_id"

  create_table "attendees", :force => true do |t|
    t.string   "given_name",                                               :null => false
    t.string   "family_name",                                              :null => false
    t.string   "gender",                   :limit => 1
    t.boolean  "anonymous"
    t.integer  "rank",                                                     :null => false
    t.integer  "aga_id"
    t.string   "address_1",                                                :null => false
    t.string   "address_2"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "country",                  :limit => 2
    t.string   "phone"
    t.string   "email"
    t.date     "birth_date"
    t.boolean  "understand_minor"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.boolean  "is_primary",                            :default => false, :null => false
    t.boolean  "minor_agreement_received",              :default => false, :null => false
    t.integer  "congresses_attended"
    t.string   "tshirt_size",              :limit => 2
    t.text     "special_request"
    t.text     "roomate_request"
    t.string   "comment"
    t.boolean  "confirmed"
    t.string   "guardian_full_name"
    t.integer  "year",                                                     :null => false
  end

  add_index "attendees", ["aga_id", "year"], :name => "index_attendees_on_aga_id_and_year", :unique => true
  add_index "attendees", ["id", "year"], :name => "index_attendees_on_id_and_year", :unique => true
  add_index "attendees", ["user_id"], :name => "index_attendees_on_user_id"

  create_table "content_categories", :force => true do |t|
    t.integer  "year",                     :null => false
    t.string   "name",       :limit => 50
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "content_categories", ["id", "year"], :name => "index_content_categories_on_id_and_year", :unique => true

  create_table "contents", :force => true do |t|
    t.text     "body",                :null => false
    t.string   "subject",             :null => false
    t.datetime "expires_at"
    t.boolean  "show_on_homepage",    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "year",                :null => false
    t.integer  "content_category_id", :null => false
  end

  add_index "contents", ["content_category_id"], :name => "index_contents_on_content_category_id"
  add_index "contents", ["year", "show_on_homepage", "expires_at"], :name => "index_contents_on_year_and_show_on_homepage_and_expires_at"

  create_table "discounts", :force => true do |t|
    t.string   "name",         :limit => 50, :null => false
    t.decimal  "amount",                     :null => false
    t.integer  "age_min"
    t.integer  "age_max"
    t.boolean  "is_automatic",               :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "min_reg_date"
    t.integer  "year",                       :null => false
  end

  add_index "discounts", ["id", "year"], :name => "index_discounts_on_id_and_year", :unique => true
  add_index "discounts", ["year", "is_automatic"], :name => "index_discounts_on_year_and_is_automatic"

  create_table "events", :force => true do |t|
    t.integer "year", :null => false
    t.string  "name", :null => false
  end

  add_index "events", ["id", "year"], :name => "index_events_on_id_and_year", :unique => true

  create_table "jobs", :force => true do |t|
    t.string   "jobname"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email"
    t.integer  "total_needed"
    t.integer  "vacancies"
    t.text     "description"
    t.integer  "year",         :null => false
  end

  add_index "jobs", ["id", "year"], :name => "index_jobs_on_id_and_year", :unique => true

  create_table "plan_categories", :force => true do |t|
    t.string   "name",                           :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "year",                           :null => false
    t.string   "description"
    t.integer  "event_id",                       :null => false
    t.boolean  "mandatory",   :default => false, :null => false
  end

  add_index "plan_categories", ["id", "year"], :name => "index_plan_categories_on_id_and_year", :unique => true

  create_table "plans", :force => true do |t|
    t.string   "name",                 :limit => 50,                                                   :null => false
    t.decimal  "price",                              :precision => 10, :scale => 2,                    :null => false
    t.integer  "age_min",                                                                              :null => false
    t.integer  "age_max"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
    t.integer  "plan_category_id",                                                                     :null => false
    t.integer  "max_quantity",                                                      :default => 1,     :null => false
    t.integer  "year",                                                                                 :null => false
    t.integer  "inventory"
    t.boolean  "needs_staff_approval",                                              :default => false, :null => false
  end

  add_index "plans", ["id", "year"], :name => "index_plans_on_id_and_year", :unique => true
  add_index "plans", ["plan_category_id"], :name => "index_plans_on_plan_category_id"

  create_table "rounds", :force => true do |t|
    t.datetime "round_start",   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "tournament_id"
  end

  add_index "rounds", ["tournament_id", "round_start"], :name => "index_rounds_on_tournament_id_and_round_start", :unique => true

  create_table "tournaments", :force => true do |t|
    t.string   "name",                      :limit => 50,                    :null => false
    t.string   "eligible",                                                   :null => false
    t.text     "description",                                                :null => false
    t.string   "directors",                                                  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "openness",                  :limit => 1,  :default => "O",   :null => false
    t.boolean  "show_attendee_notes_field",               :default => false, :null => false
    t.integer  "year",                                                       :null => false
    t.string   "location",                  :limit => 50
    t.boolean  "show_in_nav_menu",                        :default => false, :null => false
  end

  add_index "tournaments", ["id", "year"], :name => "index_tournaments_on_id_and_year", :unique => true

  create_table "transactions", :force => true do |t|
    t.integer  "user_id",                                                        :null => false
    t.string   "trantype",           :limit => 1,                                :null => false
    t.decimal  "amount",                          :precision => 10, :scale => 2, :null => false
    t.integer  "gwtranid"
    t.date     "gwdate"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "check_number"
    t.integer  "updated_by_user_id"
    t.string   "comment"
    t.string   "instrument",         :limit => 1
    t.integer  "year",                                                           :null => false
  end

  add_index "transactions", ["gwtranid"], :name => "index_transactions_on_gwtranid", :unique => true
  add_index "transactions", ["user_id"], :name => "index_transactions_on_user_id"
  add_index "transactions", ["year", "created_at"], :name => "index_transactions_on_year_and_created_at"

  create_table "user_jobs", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "job_id"
    t.integer  "year",       :null => false
  end

  add_index "user_jobs", ["job_id"], :name => "index_user_jobs_on_job_id"
  add_index "user_jobs", ["user_id", "job_id"], :name => "uniq_user_job", :unique => true

  create_table "users", :force => true do |t|
    t.string   "email",                               :default => "",  :null => false
    t.string   "encrypted_password",   :limit => 128, :default => "",  :null => false
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                       :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "role",                 :limit => 1,   :default => "U", :null => false
    t.integer  "year",                                                 :null => false
  end

  add_index "users", ["email", "year"], :name => "index_users_on_email_and_year", :unique => true
  add_index "users", ["id", "year"], :name => "index_users_on_id_and_year", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["year"], :name => "index_users_on_year"

end
