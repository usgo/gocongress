class AddEmergencyNameToAttendees < ActiveRecord::Migration
  def change
    add_column :attendees, :emergency_name, :string, limit: 255
  end
end
