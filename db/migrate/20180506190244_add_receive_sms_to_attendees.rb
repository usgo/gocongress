class AddReceiveSmsToAttendees < ActiveRecord::Migration[5.0]
  def change
    add_column :attendees, :receive_sms, :boolean, default: nil
  end
end
