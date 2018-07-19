class AddTournamentsToGameAppointments < ActiveRecord::Migration[5.0]
  def change
    add_reference :game_appointments, :tournament, foreign_key: true
  end
end
