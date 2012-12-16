class AlterAttendeesRemoveCongressesAttended < ActiveRecord::Migration
  def up
    remove_column :attendees, :congresses_attended
  end

  def down
  	add_column :attendees, :congresses_attended, :integer
  end
end
