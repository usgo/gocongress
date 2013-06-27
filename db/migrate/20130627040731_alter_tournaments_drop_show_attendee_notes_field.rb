class AlterTournamentsDropShowAttendeeNotesField < ActiveRecord::Migration
  def up
    remove_column :tournaments, :show_attendee_notes_field
  end

  def down
    add_column :tournaments, :show_attendee_notes_field, \
      :boolean, {:null=>false, :default=>false}
  end
end
