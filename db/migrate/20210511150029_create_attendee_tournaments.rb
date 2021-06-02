class CreateAttendeeTournaments < ActiveRecord::Migration[5.0]
  def change
    create_table :attendee_tournaments do |t|
      t.references :attendee, foreign_key: true
      t.references :tournament, foreign_key: true

      t.timestamps
    end
  end
end
