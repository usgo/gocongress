require 'test_helper'

class AttendeeTest < ActiveSupport::TestCase
  setup do
    @user = Factory.create(:user)
    @plan = Factory.create(:plan)
  end

  test "factory is valid" do
    assert Factory.build(:attendee).valid?
  end

  test "country must be two capital lettters" do
    assert_match( /^[A-Z]{2}$/, @user.primary_attendee.country )
    update_success = @user.primary_attendee.update_attributes( { :country => 'United States' } )
    assert !update_success
  end

  test "destroying an attendee also destroys dependent AttendeePlans" do
    a = Factory(:attendee, :user_id => @user.id)
    a.plans << @plan

    # when we destroy the attendee, we expect all dependent AttendeePlans to be destroyed
    destroyed_attendee_id = a.id
    assert_difference('AttendeePlan.count', -1) do
      a.destroy
    end

    # double check
    assert_equal 0, AttendeePlan.where(:attendee_id => destroyed_attendee_id).count
  end

end
