require 'test_helper'

class EventTest < ActiveSupport::TestCase
  test "factory is valid" do
    assert Factory(:event).valid?
  end
end
