class CreateByeAppointments < ActiveRecord::Migration[5.0]
  def change
    create_table :bye_appointments do |t|
      t.references :round, foreign_key: true
      t.references :attendee, foreign_key: true

      t.timestamps
    end
  end
end
