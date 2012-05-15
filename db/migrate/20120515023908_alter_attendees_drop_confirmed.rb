class AlterAttendeesDropConfirmed < ActiveRecord::Migration
  def up
    remove_column :attendees, :confirmed
  end

  def down
    add_column :attendees, :confirmed, :boolean
  end
end
