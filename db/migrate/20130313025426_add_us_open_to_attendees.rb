class AddUsOpenToAttendees < ActiveRecord::Migration
  def change
    add_column :attendees, :will_play_in_us_open, :boolean
  end
end
