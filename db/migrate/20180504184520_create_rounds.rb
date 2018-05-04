class CreateRounds < ActiveRecord::Migration[5.0]
  def change
    create_table :rounds do |t|
      t.references :tournament, foreign_key: true
      t.integer :number
      t.datetime :start_time, null: false
      
      t.timestamps
    end
  end
end
