class AddNotesToAttendeeTournaments < ActiveRecord::Migration
  def self.up
    add_column :attendee_tournaments, :notes, :string
  end

  def self.down
    remove_column :attendee_tournaments, :notes
  end
end
