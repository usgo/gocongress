# `PlanSelection` is a data class, representing an attendee's
# choice of a plan on the registration form.  It is a useful
# abstraction to pass between eg. AttendeesController and
# Registration. -Jared 2012-10-07
class Registration::PlanSelection
  attr_reader :plan, :qty
  def initialize plan, qty
    @plan = plan
    @qty = qty
  end

  # Two plan selections are `eql?` if they have all of the same
  # attributes.  This definition of equality was chosen to support
  # operations on sets of selections, eg. union and intersection.
  def eql? other
    plan == other.plan && qty == other.qty
  end

  # Ruby's `Set` requires `hash`.  Note that definition of `hash`
  # must conform to definition of `eql?`
  def hash
    (plan.id.to_s + qty.to_s).hash
  end

  def to_attendee_plan attendee
    AttendeePlan.new(:attendee_id => attendee.id,
      :plan_id => @plan.id, :quantity => @qty)
  end
end
