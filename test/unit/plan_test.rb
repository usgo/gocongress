require 'test_helper'

class PlanTest < ActiveSupport::TestCase
  test "factory is valid" do
    assert Factory.build(:plan).valid?
  end

  test "a plan with neither rooms nor meals is invalid" do
    p = Factory.build(:plan)
    p.has_rooms = false
    p.has_meals = false
    assert_equal false, p.valid?
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
