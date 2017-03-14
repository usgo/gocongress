class AddLocalPhoneToAttendees < ActiveRecord::Migration
  def change
    add_column :attendees, :local_phone, :string, limit: 255
  end
end
