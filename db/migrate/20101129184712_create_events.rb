class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.string :evtname
      t.string :evtdeparttime
      t.string :evtstarttime
      t.string :evtprice

      t.timestamps
    end
  end

  def self.down
    drop_table :events
  end
end
