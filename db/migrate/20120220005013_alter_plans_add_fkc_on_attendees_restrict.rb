require "postgres_migration_helpers"

class AlterPlansAddFkcOnAttendeesRestrict < ActiveRecord::Migration
  extend PostgresMigrationHelpers

  # change the existing FKC from cascade to restrict

  def self.up
    remove_pg_foreign_key :attendee_plans, [:plan_id, :year]
    add_pg_foreign_key :attendee_plans, [:plan_id, :year], :plans, [:id, :year], :restrict
  end

  def self.down
    remove_pg_foreign_key :attendee_plans, [:plan_id, :year]
    add_pg_foreign_key :attendee_plans, [:plan_id, :year], :plans, [:id, :year]
  end
end
