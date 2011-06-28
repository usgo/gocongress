class AttendeeEvent < ActiveRecord::Base
  belongs_to :attendee
  belongs_to :event
  validates_presence_of :attendee, :event
end
