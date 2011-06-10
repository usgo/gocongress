require 'test_helper'

class AttendeePlanTest < ActiveSupport::TestCase

  test "qty less than 1 is invalid" do
    u = Factory(:user)
    u.attendees << Factory(:attendee, :user_id => u.id)
    p = Factory :plan, :max_quantity => 1
    ap = AttendeePlan.new \
      :attendee_id => u.attendees.first \
      , :plan_id => p.id \
      , :quantity => 0
    assert !ap.valid?
    ap.quantity = -1
    assert !ap.valid?
    ap.quantity = 1
    assert ap.valid?
  end

end
