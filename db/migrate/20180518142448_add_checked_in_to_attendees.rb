class AddCheckedInToAttendees < ActiveRecord::Migration[5.0]
  def change
    add_column :attendees, :checked_in, :boolean, default: false
  end
end
