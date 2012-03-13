class AddTransportationRequestToAttendees < ActiveRecord::Migration
  def change
    add_column :attendees, :transportation_request, :string, :limit => 500
  end
end
