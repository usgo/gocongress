class AddRoundToGameAppointments < ActiveRecord::Migration[5.0]
  def change
    add_reference :game_appointments, :round, foreign_key: true
  end
end
