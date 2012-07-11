class DropJobs < ActiveRecord::Migration
  def up
    drop_table :user_jobs
    drop_table :jobs
  end

  def down
    raise IrreversibleMigration # not really, just lazy
  end
end
