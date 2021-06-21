class RemoveUsOpenFromAttendees < ActiveRecord::Migration[5.2]
  def change
    remove_column :attendees, :will_play_in_us_open
  end
end
