class AlterEventsDepartTime < ActiveRecord::Migration

  class Event < ActiveRecord::Base
  end

  def up
    add_column :events, :depart_time, :time
    Event.reset_column_information
    Event.to_a.each do |e|

      # Does evtdeparttime, the poorly-conceived string,
      # contain a useful time, eg. 11:30 PM?
      rematches = e.evtdeparttime.match('^(\d{1,2}):(\d{2})[ ]?(am|pm|AM|PM)')
      if rematches.present? && rematches.length == 4
        hour = rematches[1].to_i
        minute = rematches[2].to_i
        meridian = rematches[3].downcase

        # Convert to 24 hour time on a scale of 0 to 23
        if (hour == 12 && meridian == 'am')
          hour24 = 0
        elsif (hour == 12 && meridian == 'pm')
          hour24 = 12
        elsif meridian == 'am'
          hour24 = hour
        elsif meridian == 'pm'
          hour24 = hour + 12
        else
          raise "Unable to convert to 24 hour time"
        end

        # Save the extracted time in our new depart_time column.
        # The year, month, and day are ignored by the codebase.
        # Jan. 1, 2000 appears to be the rails default date when
        # one uses a time_select in one's form.
        e.depart_time = Time.utc(2000, 1, 1, hour24, minute)
        e.save!
      end
    end
  end

  def down
    remove_column :events, :depart_time
  end
end
