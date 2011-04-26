require 'test_helper'

class PlanTest < ActiveSupport::TestCase
  setup do
    @prices_category = Factory(:prices_category)
    @roomboard_category = Factory(:roomboard_category)
  end

  test "factory is valid" do
    assert Factory.build(:plan).valid?
  end
end
