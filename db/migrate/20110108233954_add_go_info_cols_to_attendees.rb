class AddGoInfoColsToAttendees < ActiveRecord::Migration
  def self.up
    add_column :attendees, :is_player, :boolean
    add_column :attendees, :will_play_in_us_open, :boolean
  end

  def self.down
    remove_column :attendees, :will_play_in_us_open
    remove_column :attendees, :is_player
  end
end
