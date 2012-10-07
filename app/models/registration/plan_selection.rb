# `PlanSelection` is a data class, representing an attendee's
# choice of a plan on the registration form.  It is a useful
# abstraction to pass between eg. AttendeesController and Registrar.
# -Jared 2012-10-07
class Registration::PlanSelection
  attr_reader :plan, :qty
  def initialize plan, qty
    @plan = plan
    @qty = qty
  end
end
