class AddGuardianFullNameToAttendees < ActiveRecord::Migration
  def self.up
    add_column :attendees, :guardian_full_name, :string
  end

  def self.down
    remove_column :attendees, :guardian_full_name
  end
end
