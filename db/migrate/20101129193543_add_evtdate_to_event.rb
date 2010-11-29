class AddEvtdateToEvent < ActiveRecord::Migration
  def self.up
    add_column :events, :evtdate, :date
  end

  def self.down
    remove_column :events, :evtdate
  end
end
