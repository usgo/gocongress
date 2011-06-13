class CreateAttendeeTournaments < ActiveRecord::Migration
  def self.up
    create_table :attendee_tournaments do |t|
      t.integer :attendee_id, :null => false
      t.integer :tournament_id, :null => false
      t.timestamps
    end
    
    # create unique index
    add_index :attendee_tournaments, \
      [:attendee_id, :tournament_id], \
      { :name => :uniq_attendee_tournament, :unique => true }
  end

  def self.down
    remove_index :attendee_tournaments, :name => :uniq_attendee_tournament
    drop_table :attendee_tournaments
  end
end
