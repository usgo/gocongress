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

ActiveRecord::Schema.define(:version => 20110115232334) do

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
    t.string   "password_salt",                       :default => "",    :null => false
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
