class DropEventstarttime < ActiveRecord::Migration
  def self.up
    remove_column :events, :evtstarttime
  end

  def self.down
    raise IrreversibleMigration
  end
end
