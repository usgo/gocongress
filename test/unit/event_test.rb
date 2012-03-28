require 'test_helper'

class EventTest < ActiveSupport::TestCase

  test "factory is valid" do
    assert FactoryGirl.build(:event).valid?
  end

end
