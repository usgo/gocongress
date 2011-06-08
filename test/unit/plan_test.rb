require 'test_helper'

class PlanTest < ActiveSupport::TestCase
  setup do
    @prices_category = Factory(:prices_category)
    @roomboard_category = Factory(:roomboard_category)
  end

  test "factory is valid" do
    assert Factory.build(:plan).valid?
  end

  test "max qty" do
    p = Factory.build(:plan, :max_quantity => 1)
    assert p.valid?
    p.max_quantity = 0
    assert !p.valid?
    p.max_quantity = -1
    assert !p.valid?
  end
end
