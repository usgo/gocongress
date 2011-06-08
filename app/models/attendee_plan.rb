class AttendeePlan < ActiveRecord::Base
  belongs_to :attendee
  belongs_to :plan

  # attr_accessible is not necessary, because
  # there is no AttendeePlan controller

  validates_numericality_of :quantity, \
    :only_integer => true, \
    :greater_than_or_equal_to => 1, \
    :less_than_or_equal_to => :get_plan_max_qty

private

  def get_plan_max_qty
    self.plan.max_quantity
  end

end
