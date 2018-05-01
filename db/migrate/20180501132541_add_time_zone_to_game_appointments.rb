class AddTimeZoneToGameAppointments < ActiveRecord::Migration[5.0]
  def change
    add_column :game_appointments, :time_zone, :string
  end
end
