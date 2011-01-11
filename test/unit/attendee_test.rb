require 'test_helper'

class AttendeeTest < ActiveSupport::TestCase
  setup do
    @user = Factory.create(:user)
  end

  test "factory is valid" do
    assert Factory.build(:attendee).valid?
  end

  test "can not destroy primary attendee" do
    assert_difference('Attendee.count', 0) do
      @user.primary_attendee.destroy
    end
  end
end
