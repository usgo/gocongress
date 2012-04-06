class AddFlyingToAttendees < ActiveRecord::Migration
  def change
    add_column :attendees, :flying, :boolean, :null => false, :default => false
  end
end
