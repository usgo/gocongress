require 'test_helper'

class PlanTest < ActiveSupport::TestCase
  setup do
    @prices_category = Factory(:prices_category)
    @roomboard_category = Factory(:roomboard_category)
  end

  test "factory is valid" do
    assert Factory.build(:plan).valid?
  end

  test "a roomboard plan with neither rooms nor meals is invalid" do
    p = Factory.build(:plan)
    p.has_rooms = false
    p.has_meals = false
    p.plan_category_id = @roomboard_category.id
    assert_equal false, p.valid?
  end

  test "an extras plan with neither rooms nor meals is valid" do
    p = Factory.build(:plan)
    p.has_rooms = false
    p.has_meals = false
    p.plan_category_id = @prices_category.id
    assert_equal true, p.valid?
  end

  test "a plan with rooms or meals or both is valid" do
    p = Factory.build(:plan)
    p.has_rooms = [true, false].sample
    p.has_meals = !p.has_rooms
    assert p.valid?
    p.has_rooms = true
    p.has_meals = true
    assert p.valid?
  end
end
