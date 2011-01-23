class AddEmailToJob < ActiveRecord::Migration
  def self.up
    add_column :jobs, :email, :string
  end

  def self.down
    remove_column :jobs, :email
  end
end
