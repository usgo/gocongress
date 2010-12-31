class AlterUserDotIsAdminSetDefault < ActiveRecord::Migration
  def self.up
  	change_column(:users, :is_admin, :boolean, :default => false)
  end

  def self.down
  	change_column(:users, :is_admin, :boolean)
  end
end
