require 'test_helper'

class AttendeeTest < ActiveSupport::TestCase
  test "factory is valid" do
    assert Factory.build(:attendee).valid?
  end
end
