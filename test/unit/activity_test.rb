require 'test_helper'

class EventTest < ActiveSupport::TestCase
  test "factory is valid" do
    assert Factory(:activity).valid?
  end
end
