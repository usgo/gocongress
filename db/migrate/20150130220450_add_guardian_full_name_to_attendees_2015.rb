class AddGuardianFullNameToAttendees2015 < ActiveRecord::Migration
  def change
    add_column :attendees, :guardian_full_name, :string
  end
end
