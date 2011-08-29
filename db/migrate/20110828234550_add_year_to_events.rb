class AddYearToEvents < ActiveRecord::Migration
  def up
    add_column :events, :year, :integer
    Event.update_all :year => 2011
    change_column :events, :year, :integer, :null => false
  end

  def down
    remove_column :events, :year
  end
end
