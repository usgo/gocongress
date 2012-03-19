require 'test_helper'

class PlansControllerTest < ActionController::TestCase
  setup do
    @plan = Factory :plan
    @year = Time.now.year
  end

  test "non-admin cannot get new" do
    sign_in Factory :user
    get :new, :year => @year
    assert_response 403
  end

  test "non-admin cannot create plan" do
    sign_in Factory :user
    post :create, :plan => @plan.attributes, :year => @year
    assert_response 403
  end
  
  test "admin can create plan" do
    sign_in Factory :admin
    assert_difference('Plan.count') do
      post :create, :plan => @plan.attributes, :year => @year
    end
    assert_redirected_to plan_category_path(@plan.plan_category)
  end

  test "visitor can show plan" do
    get :show, :id => @plan.to_param, :year => @year
    assert_response :success
  end

  test "admin can set max quantity" do
    sign_in Factory :admin
    new_max_quantity = 100+rand(10)
    assert_not_equal @plan.max_quantity, new_max_quantity
    @plan.max_quantity = new_max_quantity
    put :update, :id => @plan.id, :plan => @plan.attributes, :year => @year
    plan_after = Plan.find @plan.id
    assert_equal new_max_quantity, plan_after.max_quantity
    assert_redirected_to plan_category_path(@plan.plan_category)
  end

end
