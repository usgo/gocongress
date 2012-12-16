class AttendeeStatisticsController < ApplicationController

def index

  # The filtering logic here should match AttendeesController#index
  # TODO: DRY this up by pushing it into the model
  @attendees = Attendee.yr(@year).with_at_least_one_plan

  # who is going to which events?
  @evt_stats = {}
  Event.yr(@year).each { |evt|
    @evt_stats[evt.name] = @attendees.has_plan_in_event(evt).count
  }

  # get some fun statistics
  @pro_count = @attendees.pro.count
  @dan_count = @attendees.dan.count
  @kyu_count = @attendees.kyu.count
  @np_count = @attendees.where(:rank => 0).count
  @male_count = @attendees.where(:gender => 'm').count
  @female_count = @attendees.where(:gender => 'f').count

  # for the age statistics, our query will use a different order clause
  age_before_beauty = Attendee.yr(@year).reasonable_birth_date.order('birth_date')
  @oldest_attendee = age_before_beauty.first
  @youngest_attendee = age_before_beauty.last

  # calculate average age, being careful not to call reduce on an empty array
  ages = @attendees.reasonable_birth_date.all.map(&:age_in_years)
  @avg_age = ages.empty? ? nil : ages.reduce(:+) / ages.count
end

end
