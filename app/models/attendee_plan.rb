class AttendeePlan < ActiveRecord::Base
  belongs_to :attendee
  belongs_to :plan

  # attr_accessible is not necessary, because
  # there is no AttendeePlan controller

  validates_numericality_of :quantity, :only_integer => true, :greater_than_or_equal_to => 1
end
