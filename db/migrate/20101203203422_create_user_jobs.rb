class CreateUserJobs < ActiveRecord::Migration
  def self.up
    create_table :user_jobs do |t|
      t.timestamps
    end
  end

  def self.down
    drop_table :user_jobs
  end
end
