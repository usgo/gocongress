class AddTableToGameAppointments < ActiveRecord::Migration[5.0]
  def change
    add_column :game_appointments, :table, :integer, null: false
    add_column :game_appointments, :result, :string
    add_column :game_appointments, :handicap, :integer
  end
end
