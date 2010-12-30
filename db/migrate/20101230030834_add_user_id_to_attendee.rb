class AddUserIdToAttendee < ActiveRecord::Migration
  def self.up
    add_column :attendees, :user_id, :integer
  end

  def self.down
    remove_column :attendees, :user_id
  end
end
