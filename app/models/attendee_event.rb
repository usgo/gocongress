class AttendeeEvent < ActiveRecord::Base
  belongs_to :attendee
  belongs_to :event
  validates_presence_of :attendee, :event
  validates :year, :numericality => { :only_integer => true, :greater_than => 2010, :less_than => 2100 }

  before_validation do |ae|
    if ae.event.year != ae.attendee.year
      raise "Attendee and Event have different years"
    end
    ae.year ||= ae.attendee.year
  end
end
