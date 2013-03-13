require "postgres_migration_helpers"

class DropGuardianFullNameFromAttendees < ActiveRecord::Migration
  include PostgresMigrationHelpers

  def up
    remove_column :attendees, :guardian_full_name
    add_column :attendees, :guardian_attendee_id, :integer
    add_pg_foreign_key \
      :attendees, [:guardian_attendee_id, :year],
      :attendees, [:id, :year],
      'restrict', 'simple'
  end

  def down
    remove_pg_foreign_key :attendees, [:guardian_attendee_id, :year]
    remove_column :attendees, :guardian_attendee_id
    add_column :attendees, :guardian_full_name, :string
  end
end
