class AddUsernameFieldsToAttendee < ActiveRecord::Migration[5.2]
  def change
    add_column :attendees, :username_kgs, :string
    add_column :attendees, :username_igs, :string
    add_column :attendees, :username_ogs, :string
  end
end
