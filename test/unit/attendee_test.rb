require 'test_helper'

class AttendeeTest < ActiveSupport::TestCase
  setup do
    @user = Factory.create(:user)
  end

  test "factory is valid" do
    assert Factory.build(:attendee).valid?
  end

  test "country must be two capital lettters" do
    assert_match( /^[A-Z]{2}$/, @user.primary_attendee.country )
    update_success = @user.primary_attendee.update_attributes( { :country => 'United States' } )
    assert !update_success
  end

end
