class CreateAttendeeEvents < ActiveRecord::Migration
  def up
    create_table :attendee_events do |t|
      t.integer :attendee_id, :null => false
      t.integer :event_id, :null => false
      t.timestamps
    end
    
    add_index :attendee_events, \
      [:attendee_id, :event_id], \
      { :name => :uniq_attendee_event, :unique => true }
  end

  def down
    drop_table :attendee_events
  end
end
