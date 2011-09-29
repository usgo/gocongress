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

ActiveRecord::Schema.define(:version => 20110929054500) do

  create_table "attendee_discounts", :force => true do |t|
    t.integer  "attendee_id", :null => false
    t.integer  "discount_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "attendee_discounts", ["attendee_id", "discount_id"], :name => "uniq_attendee_discount", :unique => true

  create_table "attendee_events", :force => true do |t|
    t.integer  "attendee_id", :null => false
    t.integer  "event_id",    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "attendee_events", ["attendee_id", "event_id"], :name => "uniq_attendee_event", :unique => true

  create_table "attendee_plans", :force => true do |t|
    t.integer  "attendee_id",                :null => false
    t.integer  "plan_id",                    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "quantity",    :default => 1, :null => false
  end

  add_index "attendee_plans", ["attendee_id", "plan_id"], :name => "uniq_attendee_plan", :unique => true

  create_table "attendee_tournaments", :force => true do |t|
    t.integer  "attendee_id",   :null => false
    t.integer  "tournament_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "notes"
  end

  add_index "attendee_tournaments", ["attendee_id", "tournament_id"], :name => "uniq_attendee_tournament", :unique => true

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
    t.boolean  "is_player"
    t.boolean  "is_current_aga_member"
    t.string   "tshirt_size",              :limit => 2
    t.text     "special_request"
    t.text     "roomate_request"
    t.date     "deposit_received_at"
    t.string   "comment"
    t.boolean  "confirmed"
    t.string   "guardian_full_name"
    t.integer  "year",                                                     :null => false
  end

  create_table "contents", :force => true do |t|
    t.text     "body",             :null => false
    t.string   "subject",          :null => false
    t.datetime "expires_at"
    t.boolean  "show_on_homepage", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "year",             :null => false
    t.boolean  "is_faq",           :null => false
  end

  create_table "discounts", :force => true do |t|
    t.string   "name",         :limit => 50,                    :null => false
    t.decimal  "amount",                                        :null => false
    t.integer  "age_min"
    t.integer  "age_max"
    t.boolean  "is_automatic",                                  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "players_only",               :default => false, :null => false
    t.date     "min_reg_date"
    t.integer  "year",                                          :null => false
  end

  create_table "events", :force => true do |t|
    t.string   "evtname"
    t.string   "evtdeparttime"
    t.string   "evtprice"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "start"
    t.string   "notes",              :limit => 250
    t.time     "return_depart_time"
    t.time     "return_arrive_time"
    t.integer  "year",                              :null => false
  end

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

  create_table "plan_categories", :force => true do |t|
    t.string   "name",                   :null => false
    t.boolean  "show_on_prices_page",    :null => false
    t.boolean  "show_on_roomboard_page", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "show_on_reg_form"
    t.integer  "year",                   :null => false
  end

  create_table "plans", :force => true do |t|
    t.string   "name",             :limit => 50,                :null => false
    t.decimal  "price",                                         :null => false
    t.integer  "age_min",                                       :null => false
    t.integer  "age_max"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
    t.integer  "plan_category_id"
    t.integer  "max_quantity",                   :default => 1, :null => false
    t.integer  "year",                                          :null => false
  end

  create_table "rounds", :force => true do |t|
    t.datetime "round_start",   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "tournament_id"
  end

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
  end

  create_table "transactions", :force => true do |t|
    t.integer  "user_id",                         :null => false
    t.string   "trantype",           :limit => 1, :null => false
    t.decimal  "amount",                          :null => false
    t.integer  "gwtranid"
    t.date     "gwdate"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "check_number"
    t.integer  "updated_by_user_id"
    t.string   "comment"
    t.string   "instrument",         :limit => 1
    t.integer  "year",                            :null => false
  end

  create_table "user_jobs", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "job_id"
  end

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
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
