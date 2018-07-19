class RemoveColumnsFromGameAppointments < ActiveRecord::Migration[5.0]
  def change
    remove_reference :game_appointments, :attendee, foreign_key: true
    remove_column :game_appointments, :opponent, :string
  end
end
