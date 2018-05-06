class AddTableToGameAppointments < ActiveRecord::Migration[5.0]
  def change
    add_column :game_appointments, :table, :string, null: false
  end
end
