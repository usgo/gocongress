class AddDepositReceivedAtToAttendee < ActiveRecord::Migration
  def self.up
    add_column :attendees, :deposit_received_at, :date
  end

  def self.down
    remove_column :attendees, :deposit_received_at
  end
end
