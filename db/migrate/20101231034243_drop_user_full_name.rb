class DropUserFullName < ActiveRecord::Migration
  def self.up
    remove_column :users, :full_name
  end

  def self.down
    add_column :users, :full_name, :string
  end
end
