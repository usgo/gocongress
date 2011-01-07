class AddIsPrimaryToAttendee < ActiveRecord::Migration
  def self.up
    add_column :attendees, :is_primary, :boolean, { :null => false, :default => false }
  end

  def self.down
    remove_column :attendees, :is_primary
  end
end
