class AddYearToContents < ActiveRecord::Migration
  def up
    add_column :contents, :year, :integer
    Content.update_all :year => 2011
    change_column :contents, :year, :integer, :null => false
  end

  def down
    remove_column :contents, :year
  end
end
