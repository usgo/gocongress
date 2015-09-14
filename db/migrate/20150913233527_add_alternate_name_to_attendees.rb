class AddAlternateNameToAttendees < ActiveRecord::Migration
  def change
    add_column :attendees, :alternate_name, :string, limit: 255
  end
end
