class RemoveDateAndTimeFromTournament < ActiveRecord::Migration
  def self.up
    remove_column :tournaments, :time
    remove_column :tournaments, :tournament_date
  end

  def self.down
    add_column :tournaments, :time, :string
    add_column :tournaments, :tournament_date, :date
  end
end
