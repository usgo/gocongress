require 'test_helper'

class ActivityTest < ActiveSupport::TestCase
  test "factory is valid" do
    assert FactoryGirl.create(:activity).valid?
  end
end
