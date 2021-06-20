class AddShowAttendeeNotesFieldToTournaments < ActiveRecord::Migration
  def self.up
    add_column :tournaments, :show_attendee_notes_field, :boolean, { :null => false, :default => false }
  end

  def self.down
    remove_column :tournaments, :show_attendee_notes_field
  end
end
