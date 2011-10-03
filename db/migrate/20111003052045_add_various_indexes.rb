class AddVariousIndexes < ActiveRecord::Migration
  def up
    # The following indexes are for performance.  Some of these indexes
    # will not be useful immediately, especially those whose first 
    # column is year.  However, as years go by and the database grows,
    # they should become useful (year's selectivity will increase).
    add_index :users, :year
    add_index :user_jobs, :job_id
    add_index :transactions, [:year, :created_at]
    add_index :transactions, :user_id
    add_index :attendee_events, :event_id
    add_index :events, [:year, :start]
    add_index :plans, :plan_category_id
    add_index :attendee_tournaments, :tournament_id
    add_index :attendees, :user_id
    add_index :attendee_discounts, :discount_id
    add_index :discounts, [:year, :is_automatic]
    add_index :contents, [:year, :show_on_homepage, :expires_at]
    add_index :contents, [:year, :is_faq, :expires_at]

    # These indexes support uniqueness validations
    add_index :attendees, [:aga_id, :year], :unique => true
    add_index :transactions, :gwtranid, :unique => true
    add_index :rounds, [:tournament_id, :round_start], :unique => true
  end

  def down
    remove_index :users, :year
    remove_index :user_jobs, :job_id
    remove_index :transactions, [:year, :created_at]
    remove_index :transactions, :user_id
    remove_index :attendee_events, :event_id
    remove_index :events, [:year, :start]
    remove_index :plans, :plan_category_id
    remove_index :attendee_tournaments, :tournament_id
    remove_index :attendees, :user_id
    remove_index :attendee_discounts, :discount_id
    remove_index :discounts, [:year, :is_automatic]
    remove_index :contents, [:year, :show_on_homepage, :expires_at]
    remove_index :contents, [:year, :is_faq, :expires_at]
    remove_index :attendees, [:aga_id, :year]
    remove_index :transactions, :gwtranid
    remove_index :rounds, [:tournament_id, :round_start]
  end
end
