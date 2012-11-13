class AttendeeActivity < ActiveRecord::Base
  belongs_to :attendee
  belongs_to :activity

  # Mass-assignment security is unnecessary for this model because
  # it has no controller and no other models accept nested
  # attributes for it.  Currently, records are only written by
  # attendees_controller#update.  However, we know we want a
  # separate attendee_activities_controller in the future, and then
  # we will want mass-assignment security. -Jared 2012-07-15
  attr_accessible :attendee_id, :activity_id

  validates_presence_of :attendee, :activity
  validates :year, :numericality => { :only_integer => true, :greater_than => 2010, :less_than => 2100 }

  before_validation do |ae|
    if ae.activity.year != ae.attendee.year
      raise "attendee and activity have different years"
    end
    ae.year ||= ae.attendee.year
  end
end
