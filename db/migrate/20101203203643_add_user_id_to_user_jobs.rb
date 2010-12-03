class AddUserIdToUserJobs < ActiveRecord::Migration
  def self.up
    add_column :user_jobs, :user_id, :integer
  end

  def self.down
    remove_column :user_jobs, :user_id
  end
end
