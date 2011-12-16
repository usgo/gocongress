class DropDepositReceivedAtFromAttendees < ActiveRecord::Migration
  def up
    remove_column :attendees, :deposit_received_at
  end

  def down
    add_column :attendees, :deposit_received_at, :date
  end
end
