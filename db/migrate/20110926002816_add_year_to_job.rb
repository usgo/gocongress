class AddYearToJob < ActiveRecord::Migration
  def up
    add_column :jobs, :year, :integer
    Job.update_all :year => 2011
    change_column :jobs, :year, :integer, :null => false
  end
  
  def down
    remove_column :jobs, :year
  end
end
