class PopulateEventStart < ActiveRecord::Migration
  def self.up
    Event.all.each { |e|
      e.start = e.evtdate.to_s + " " + e.evtstarttime.to_s
      e.save
    }
  end

  def self.down
    raise IrreversibleMigration
  end
end
