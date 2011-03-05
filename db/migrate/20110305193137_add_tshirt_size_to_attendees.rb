class AddTshirtSizeToAttendees < ActiveRecord::Migration
  def self.up
    add_column :attendees, :tshirt_size, :string, :limit => 2
  end

  def self.down
    remove_column :attendees, :tshirt_size
  end
end
