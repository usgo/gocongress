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

ActiveRecord::Schema.define(:version => 20110425042609) do

  create_table "attendee_discounts", :force => true do |t|
    t.integer  "attendee_id", :null => false
    t.integer  "discount_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "attendee_plans", :force => true do |t|
    t.integer  "attendee_id", :null => false
    t.integer  "plan_id",     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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
    t.boolean  "will_play_in_us_open"
    t.boolean  "is_current_aga_member"
    t.string   "tshirt_size",              :limit => 2
    t.text     "special_request"
    t.text     "roomate_request"
    t.date     "deposit_received_at"
    t.string   "comment"
  end

  create_table "contents", :force => true do |t|
    t.text     "body",             :null => false
    t.string   "subject",          :null => false
    t.datetime "expires_at"
    t.boolean  "show_on_homepage", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "discounts", :force => true do |t|
    t.string   "name",         :limit => 50, :null => false
    t.decimal  "amount",                     :null => false
    t.integer  "age_min"
    t.integer  "age_max"
    t.boolean  "is_automatic",               :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "events", :force => true do |t|
    t.string   "evtname"
    t.string   "evtdeparttime"
    t.string   "evtstarttime"
    t.string   "evtprice"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "evtdate"
  end

  create_table "jobs", :force => true do |t|
    t.string   "jobname"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email"
    t.integer  "total_needed"
    t.integer  "vacancies"
    t.text     "description"
  end

  create_table "plan_categories", :force => true do |t|
    t.string   "name",                   :null => false
    t.boolean  "show_on_prices_page",    :null => false
    t.boolean  "show_on_roomboard_page", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "show_on_reg_form"
  end

  create_table "plans", :force => true do |t|
    t.string   "name",             :limit => 50,                    :null => false
    t.decimal  "price",                                             :null => false
    t.integer  "age_min",                                           :null => false
    t.integer  "age_max"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
    t.boolean  "has_meals",                      :default => false, :null => false
    t.boolean  "has_rooms",                      :default => false, :null => false
    t.integer  "plan_category_id"
  end

  create_table "preregistrants", :force => true do |t|
    t.string   "firstname",  :null => false
    t.string   "lastname",   :null => false
    t.date     "preregdate", :null => false
    t.string   "ranktype",   :null => false
    t.integer  "rank",       :null => false
    t.string   "country",    :null => false
    t.string   "email",      :null => false
    t.boolean  "anonymous",  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rounds", :force => true do |t|
    t.datetime "round_start",   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "tournament_id"
  end

  create_table "tournaments", :force => true do |t|
    t.string   "name",        :limit => 50, :null => false
    t.string   "elligible",                 :null => false
    t.text     "description",               :null => false
    t.string   "directors",                 :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
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
  end

  create_table "user_jobs", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "job_id"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                               :default => "",    :null => false
    t.string   "encrypted_password",   :limit => 128, :default => "",    :null => false
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
    t.boolean  "is_admin",                            :default => false, :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
