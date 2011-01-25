class CreateTournaments < ActiveRecord::Migration
  def self.up
    create_table :tournaments do |t|
      t.string :name            , :null => false, :limit => 50
      t.string :time            , :null => false, :limit => 20
      t.string :elligible       , :null => false
      t.date :tournament_date   , :null => false
      t.text :description       , :null => false
      t.string :directors       , :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :tournaments
  end
end
