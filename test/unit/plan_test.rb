require 'test_helper'

class PlanTest < ActiveSupport::TestCase
  test "factory is valid" do
    assert Factory.build(:plan).valid?
  end
end
