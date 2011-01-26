class AddTournamentIdToRound < ActiveRecord::Migration
  def self.up
    add_column :rounds, :tournament_id, :integer
  end

  def self.down
    remove_column :rounds, :tournament_id
  end
end
