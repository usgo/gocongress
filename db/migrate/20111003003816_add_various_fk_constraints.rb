require "postgres_migration_helpers"

class AddVariousFkConstraints < ActiveRecord::Migration
  extend PostgresMigrationHelpers

  def self.up
    # The following FK constraints ensure that related objects have the same
    # year.  The unique indexes make said constraints meaningful, besides
    # being required by postgres.
    add_index :jobs, [:id, :year], :unique => true
    add_pg_foreign_key :user_jobs, [:job_id, :year], :jobs, [:id, :year]

    add_index :users, [:id, :year], :unique => true
    add_pg_foreign_key :user_jobs, [:user_id, :year], :users, [:id, :year]
    add_pg_foreign_key :transactions, [:user_id, :year], :users, [:id, :year], 'restrict'
    add_pg_foreign_key :transactions, [:updated_by_user_id, :year], :users, [:id, :year], 'set null', 'simple'
    add_pg_foreign_key :attendees, [:user_id, :year], :users, [:id, :year]

    add_index :attendees, [:id, :year], :unique => true
    add_pg_foreign_key :attendee_events, [:attendee_id, :year], :attendees, [:id, :year]
    add_pg_foreign_key :attendee_plans, [:attendee_id, :year], :attendees, [:id, :year]
    add_pg_foreign_key :attendee_tournaments, [:attendee_id, :year], :attendees, [:id, :year]
    add_pg_foreign_key :attendee_discounts, [:attendee_id, :year], :attendees, [:id, :year]

    add_index :events, [:id, :year], :unique => true
    add_pg_foreign_key :attendee_events, [:event_id, :year], :events, [:id, :year]

    add_index :plans, [:id, :year], :unique => true
    add_pg_foreign_key :attendee_plans, [:plan_id, :year], :plans, [:id, :year]

    add_index :plan_categories, [:id, :year], :unique => true
    add_pg_foreign_key :plans, [:plan_category_id, :year], :plan_categories, [:id, :year]

    add_index :tournaments, [:id, :year], :unique => true
    add_pg_foreign_key :attendee_tournaments, [:tournament_id, :year], :tournaments, [:id, :year]

    add_index :discounts, [:id, :year], :unique => true
    add_pg_foreign_key :attendee_discounts, [:discount_id, :year], :discounts, [:id, :year]

    # The rounds table needs no year column
    add_pg_foreign_key :rounds, [:tournament_id], :tournaments, [:id]
  end

  def self.down
    remove_pg_foreign_key :user_jobs, [:user_id, :year]
    remove_pg_foreign_key :user_jobs, [:job_id, :year]
    remove_pg_foreign_key :transactions, [:user_id, :year]
    remove_pg_foreign_key :transactions, [:updated_by_user_id, :year]
    remove_pg_foreign_key :attendees, [:user_id, :year]
    remove_pg_foreign_key :attendee_events, [:attendee_id, :year]
    remove_pg_foreign_key :attendee_plans, [:attendee_id, :year]
    remove_pg_foreign_key :attendee_tournaments, [:attendee_id, :year]
    remove_pg_foreign_key :attendee_discounts, [:attendee_id, :year]
    remove_pg_foreign_key :attendee_events, [:event_id, :year]
    remove_pg_foreign_key :attendee_plans, [:plan_id, :year]
    remove_pg_foreign_key :plans, [:plan_category_id, :year]
    remove_pg_foreign_key :attendee_tournaments, [:tournament_id, :year]
    remove_pg_foreign_key :attendee_discounts, [:discount_id, :year]
    remove_pg_foreign_key :rounds, [:tournament_id]

    %w[users jobs attendees events plans plan_categories tournaments discounts].each do |t|
      remove_index t.to_sym, [:id, :year]
    end
  end
end
