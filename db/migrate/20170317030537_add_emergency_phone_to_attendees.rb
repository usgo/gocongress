class AddEmergencyPhoneToAttendees < ActiveRecord::Migration
  def change
    add_column :attendees, :emergency_phone, :string, limit: 255
  end
end
