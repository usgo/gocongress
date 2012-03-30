class DropTransportationRequestFromAttendees < ActiveRecord::Migration
  def up
    remove_column :attendees, :transportation_request
  end

  def down
    add_column :attendees, :transportation_request, :string, :limit => 500
  end
end
