class CreateGameAppointments < ActiveRecord::Migration[5.0]
  def change
    create_table :game_appointments do |t|
      t.references :attendee, foreign_key: true
      t.string :opponent
      t.string :location
      t.datetime :time

      t.timestamps
    end
  end
end
