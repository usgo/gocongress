class MigrateUsOpenAttendees < ActiveRecord::Migration
  def up
    usopen = Tournament.find_by_name 'US Open'
    raise "unable to find us open" unless usopen.present?
    execute <<-EOQ
      insert into attendee_tournaments (attendee_id, tournament_id)
      select id, #{usopen.id} from attendees
      where will_play_in_us_open = 't'
        and not exists (
          select * from attendee_tournaments
          where attendee_id = attendees.id and tournament_id = #{usopen.id}
        )
    EOQ
  end

  def down
    raise IrreversibleMigration
  end
end
