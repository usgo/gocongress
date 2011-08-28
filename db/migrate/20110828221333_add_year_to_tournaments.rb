class AddYearToTournaments < ActiveRecord::Migration
  def up
    add_column :tournaments, :year, :integer
    Tournament.update_all :year => 2011
    change_column :tournaments, :year, :integer, :null => false
  end
  
  def down
    remove_column :tournaments, :year
  end
end
