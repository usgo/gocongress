# `PlanSelection` is a data class, representing an attendee's
# choice of a plan on the registration form.  It is a useful
# abstraction to pass between eg. AttendeesController and
# Registration. -Jared 2012-10-07
class Registration::PlanSelection

  attr_reader :plan, :qty, :dates

  def initialize plan, qty, dates = nil
    @plan = plan
    @qty = qty
    @dates = dates || []
  end

  # `parse_params` returns an array with a selection for *each*
  # plan, even if the selected qty is zero.
  def self.parse_params plan_parms, plans
    parms = plan_parms || {}
    plans.map { |p| parse_plan_hash(parms[p.id.to_s], p) }
  end

  # `==` is same as `eql?`.  This is [conventional](http://bit.ly/XPz0B3)
  def ==(other) self.eql?(other) end

  # Two plan selections are `eql?` (and `==`) if they have all of
  # the same attributes. This definition of equality was chosen to
  # support operations on sets of selections, eg. union and
  # intersection.
  def eql? other
    plan == other.plan && qty == other.qty && dates == other.dates
  end

  # Ruby's `Set` requires `hash`.  Note that definition of `hash`
  # must conform to definition of `eql?`
  def hash
    (plan.id.to_s + qty.to_s).hash
  end

  # Gotcha: Notice that dates are not included.
  def to_attendee_plan attendee
    AttendeePlan.new(:attendee_id => attendee.id,
      :plan_id => @plan.id, :quantity => @qty)
  end

  private

  def self.parse_plan_hash hsh, plan
    hsh.nil? ? new(plan, 0) : new(plan, hsh['qty'].to_i, hsh['dates'])
  end

end
