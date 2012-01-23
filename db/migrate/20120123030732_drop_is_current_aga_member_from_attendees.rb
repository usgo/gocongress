class DropIsCurrentAgaMemberFromAttendees < ActiveRecord::Migration
  def up
    remove_column :attendees, :is_current_aga_member
  end

  def down
    add_column :attendees, :is_current_aga_member, :boolean
  end
end
