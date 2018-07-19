class AddAttendeesToGameAppointments < ActiveRecord::Migration[5.0]
  def change
    add_reference :game_appointments, :attendee_one, foreign_key: { to_table: :attendees }
    add_reference :game_appointments, :attendee_two, foreign_key: { to_table: :attendees }
  end
end
