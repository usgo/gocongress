class RemoveTournamentFromGameAppointments < ActiveRecord::Migration[5.0]
  def change
    remove_reference :game_appointments, :tournament, foreign_key: true
  end
end
