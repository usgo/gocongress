class AddStateToAttendees < ActiveRecord::Migration[5.0]
  def change
    add_column :attendees, :state, :string, limit: 2
  end
end
