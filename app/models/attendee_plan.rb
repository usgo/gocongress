class AttendeePlan < ActiveRecord::Base
  belongs_to :attendee
  belongs_to :plan

  # attr_accessible is not necessary, because
  # there is no AttendeePlan controller
end
