class AddRequestFieldsToAttendee < ActiveRecord::Migration
  def self.up
    add_column :attendees, :special_request, :text
    add_column :attendees, :roomate_request, :text
  end

  def self.down
    remove_column :attendees, :roomate_request
    remove_column :attendees, :special_request
  end
end
