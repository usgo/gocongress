require 'test_helper'

class AttendeePlanTest < ActiveSupport::TestCase

  setup do
    @atnd = FactoryGirl.create :attendee
    @plan = FactoryGirl.create :plan, inventory: 42, max_quantity: 999
  end

  test "invalid without attendee" do
    ap = AttendeePlan.new plan_id: @plan.id, quantity: 0, year: @plan.year
    assert !ap.valid?
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
