require "postgres_migration_helpers"

class CreateAttendeePlanDates < ActiveRecord::Migration
  include PostgresMigrationHelpers

  def up
    create_table :attendee_plan_dates do |t|
      t.date :_date, null: false
      t.belongs_to :attendee_plan
    end
    add_pg_foreign_key(:attendee_plan_dates, [:attendee_plan_id], \
      :attendee_plans, [:id])
  end

  def down
    drop_table :attendee_plan_dates
  end
end
