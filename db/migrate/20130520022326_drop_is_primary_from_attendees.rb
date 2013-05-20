class DropIsPrimaryFromAttendees < ActiveRecord::Migration
  def up
    remove_column :attendees, :is_primary
  end

  def down
    add_column :attendees, :is_primary, :boolean, { :null => false, :default => false }
  end
end
