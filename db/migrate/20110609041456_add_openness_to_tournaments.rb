class AddOpennessToTournaments < ActiveRecord::Migration
  def self.up
    add_column :tournaments, :openness, :string, {:limit => 1, :null => false, :default => 'O'}
  end

  def self.down
    remove_column :tournaments, :openness
  end
end
