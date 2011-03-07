class AttendeeDiscount < ActiveRecord::Base
  belongs_to :attendee
  belongs_to :discount
end
