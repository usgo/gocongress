class AttendeePlan < ActiveRecord::Base
  belongs_to :attendee
  belongs_to :plan
end
