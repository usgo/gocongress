class DropEvtdate < ActiveRecord::Migration
  def self.up
    remove_column :events, :evtdate
  end

  def self.down
    raise IrreversibleMigration
  end
end
