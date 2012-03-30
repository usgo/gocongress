class AddTravelPlanFieldsToAttendees < ActiveRecord::Migration
  def change
    add_column :attendees, :airport_arrival, :datetime
    add_column :attendees, :airport_arrival_flight, :string
    add_column :attendees, :airport_departure, :datetime
  end
end
