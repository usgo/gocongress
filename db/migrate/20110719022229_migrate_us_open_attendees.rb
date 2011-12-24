class MigrateUsOpenAttendees < ActiveRecord::Migration
  
  # Faux model protects against validations which may be added in future
  class Tournament < ActiveRecord::Base
  end
  
  def up
    usopen = Tournament.find_by_name 'US Open'
    unless usopen.present?
      usopen = Tournament.create!(name:'US Open', 
        eligible: 'Anyone',
        description: 'The national championship',
        directors: 'TBA',
        openness: 'O',
        location: 'TBA')
    end
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
