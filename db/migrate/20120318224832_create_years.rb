class CreateYears < ActiveRecord::Migration
  include PostgresMigrationHelpers

  def up
    create_table(:years) do |t|
      t.string   :city,                 :null => false
      t.string   :date_range,           :null => false
      t.date     :day_off_date,         :null => false
      t.integer  :ordinal_number,       :null => false
      t.string   :registration_phase,   :null => false
      t.string   :reply_to_email,       :null => false
      t.date     :start_date,           :null => false
      t.string   :state,                :null => false
      t.string   :timezone,             :null => false
      t.string   :twitter_url
      t.integer  :year, :null => false
    end

    add_index :years, :year, :unique => true
    add_pg_check_constraint :years, "ordinal_number >= 27"
    add_pg_check_constraint :years, "year between 2011 and 2100"
  end

  def down
    drop_table :years
  end
end
