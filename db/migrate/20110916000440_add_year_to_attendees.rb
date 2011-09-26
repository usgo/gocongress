class AddYearToAttendees < ActiveRecord::Migration
  def up
    add_column :attendees, :year, :integer
    add_column :users, :year, :integer
    Attendee.update_all :year => 2011
    User.update_all :year => 2011
    change_column :attendees, :year, :integer, :null => false
    change_column :users, :year, :integer, :null => false
  end
  
  def down
    remove_column :attendees, :year
    remove_column :users, :year
  end
end
