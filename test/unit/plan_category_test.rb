require 'test_helper'

class PlanCategoryTest < ActiveSupport::TestCase

  test "factory is valid" do
    assert FactoryGirl.build(:plan_category).valid?
  end

end
