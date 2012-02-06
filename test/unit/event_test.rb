require 'test_helper'

class EventTest < ActiveSupport::TestCase

  test "factory is valid" do
    assert Factory.build(:event).valid?
  end

end
