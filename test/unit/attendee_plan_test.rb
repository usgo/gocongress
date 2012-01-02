require 'test_helper'

class AttendeePlanTest < ActiveSupport::TestCase

  setup do
    @user = Factory :user
  end

  test "qty less than 1 is invalid" do
    @user.attendees << Factory(:attendee, :user_id => @user.id)
    p = Factory :plan, :max_quantity => 1
    ap = AttendeePlan.new \
      :attendee_id => @user.attendees.first.id \
      , :plan_id => p.id \
      , :quantity => 0
    assert !ap.valid?
    ap.quantity = -1
    assert !ap.valid?
    ap.quantity = 1
    assert ap.valid?
  end

  test "quantity cannot exceed available inventory" do
    a = @user.primary_attendee
    p = Factory :plan, inventory: 42
    a.attendee_plans.create plan_id: p.id, quantity: 43
    assert_equal false, a.valid?
  end

  test "quantity can equal available inventory" do
    a = @user.primary_attendee
    p = Factory :plan, inventory: 42, max_quantity: 999
    ap = AttendeePlan.create attendee_id: a.id, plan_id: p.id, quantity: 42
    assert ap.valid?
  end
end
