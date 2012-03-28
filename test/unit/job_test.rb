require 'test_helper'

class JobTest < ActiveSupport::TestCase
  test "factory is valid" do
    assert FactoryGirl.build(:job).valid?
  end
end
