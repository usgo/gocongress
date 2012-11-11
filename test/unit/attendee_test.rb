require 'test_helper'

class AttendeeTest < ActiveSupport::TestCase
  setup do
    @attendee = create :attendee
    @user = @attendee.user
  end

end
