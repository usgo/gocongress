class DropFlyingFromAttendees < ActiveRecord::Migration
  def up
    remove_column :attendees, :flying
  end

  def down
    add_column :attendees, :flying, :boolean, :null => false, :default => false
  end
end
