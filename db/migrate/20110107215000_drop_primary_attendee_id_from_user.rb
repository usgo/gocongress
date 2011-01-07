class DropPrimaryAttendeeIdFromUser < ActiveRecord::Migration
  def self.up
    remove_column :users, :primary_attendee_id
  end

  def self.down
	  add_column :users, :primary_attendee_id, :integer
  end
end
