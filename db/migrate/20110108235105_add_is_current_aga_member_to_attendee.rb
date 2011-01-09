class AddIsCurrentAgaMemberToAttendee < ActiveRecord::Migration
  def self.up
    add_column :attendees, :is_current_aga_member, :boolean
  end

  def self.down
    remove_column :attendees, :is_current_aga_member
  end
end
