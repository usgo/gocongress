require 'test_helper'

class AttendeePlanTest < ActiveSupport::TestCase

  setup do
    user = Factory :user
    @atnd = user.primary_attendee
    @plan = Factory :plan, inventory: 42, max_quantity: 999
  end

  test "invalid without attendee" do
    ap = AttendeePlan.new plan_id: @plan.id, quantity: 0, year: @plan.year
    assert !ap.valid?
  end

  test "qty less than 1 is invalid" do
    ap = AttendeePlan.new attendee_id: @atnd.id, plan_id: @plan.id, quantity: 0
    assert !ap.valid?
    ap.quantity = -1
    assert !ap.valid?
    ap.quantity = 1
    assert ap.valid?
  end

  test "quantity cannot exceed available inventory" do
    @atnd.attendee_plans.build plan_id: @plan.id, quantity: 43
    assert_equal false, @atnd.valid?
  end

  test "quantity can equal available inventory" do
    @atnd.attendee_plans.build plan_id: @plan.id, quantity: 42
    assert @atnd.valid?
  end
end
