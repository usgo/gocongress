require 'test_helper'

class ActivityTest < ActiveSupport::TestCase
  test "factory is valid" do
    assert Factory(:activity).valid?
  end
end
