class AddCancelledToAttendees < ActiveRecord::Migration
  def change
    add_column :attendees, :cancelled, :boolean, :null => false, :default => false
  end
end
