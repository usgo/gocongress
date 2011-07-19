class DropWillPlayInUsOpenFromAttendees < ActiveRecord::Migration
  def up
    remove_column :attendees, :will_play_in_us_open
  end

  def down
    raise IrreversibleMigration
  end
end
