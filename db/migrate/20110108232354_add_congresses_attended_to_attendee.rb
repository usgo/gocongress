class AddCongressesAttendedToAttendee < ActiveRecord::Migration
  def self.up
    add_column :attendees, :congresses_attended, :integer
  end

  def self.down
    remove_column :attendees, :congresses_attended
  end
end
