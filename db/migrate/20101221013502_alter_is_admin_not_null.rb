class AlterIsAdminNotNull < ActiveRecord::Migration
  def self.up
    change_column :users, :is_admin, :boolean, :null => false
  end

  def self.down
    change_column :users, :is_admin, :boolean, :null => true
  end
end
