class RemoveSalt < ActiveRecord::Migration
  def self.up
    User.reset_column_information
    remove_column :users, :password_salt if User.column_names.include?('password_salt')
  end

  def self.down
    add_column :users, :password_salt, :string
  end
end
