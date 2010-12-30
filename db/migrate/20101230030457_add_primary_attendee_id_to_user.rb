class AddPrimaryAttendeeIdToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :primary_attendee_id, :integer
  end

  def self.down
    remove_column :users, :primary_attendee_id
  end
end
