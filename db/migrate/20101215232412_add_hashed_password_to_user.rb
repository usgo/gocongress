class AddHashedPasswordToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :hashed_password, :string
  end

  def self.down
    remove_column :users, :hashed_password
  end
end
