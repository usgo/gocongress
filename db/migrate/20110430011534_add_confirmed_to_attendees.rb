class AddConfirmedToAttendees < ActiveRecord::Migration
  def self.up
    add_column :attendees, :confirmed, :boolean
  end

  def self.down
    remove_column :attendees, :confirmed
  end
end
