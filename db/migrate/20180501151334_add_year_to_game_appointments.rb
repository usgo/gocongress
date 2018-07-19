class AddYearToGameAppointments < ActiveRecord::Migration[5.0]
  def change
    add_column :game_appointments, :year, :integer
  end
end
