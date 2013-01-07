class AttendeePlanDate < ActiveRecord::Base
  belongs_to :attendee_plan
  validates :attendee_plan, presence: true
  validates :_date, presence: true
end
