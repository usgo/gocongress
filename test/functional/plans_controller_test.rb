require 'test_helper'

class PlansControllerTest < ActionController::TestCase
  setup do
    @plan = Factory.create(:plan)
    @user = Factory.create(:user)
    @admin = Factory.create(:admin)
    @year = Time.now.year
  end

  test "visitors cannot get index" do
    get :index, :year => @year
    assert_response 403
  end

  test "admins can get index" do
    sign_in @admin
    get :index, :year => @year
    assert_response :success
  end

  test "non-admin cannot get new" do
    sign_in @user
    get :new, :year => @year
    assert_response 403
  end

  test "non-admin cannot create plan" do
    sign_in @user
    post :create, :plan => @plan.attributes, :year => @year
    assert_response 403
  end
  
  test "admin can create plan" do
    sign_in @admin
    assert_difference('Plan.count') do
      post :create, :plan => @plan.attributes, :year => @year
    end
    assert_redirected_to plans_path
  end

  test "visitor can show plan" do
    get :show, :id => @plan.to_param, :year => @year
    assert_response :success
  end

  test "admin can set max quantity" do
    sign_in @admin
    new_max_quantity = 100+rand(10)
    assert_not_equal @plan.max_quantity, new_max_quantity
    @plan.max_quantity = new_max_quantity
    put :update, :id => @plan.id, :plan => @plan.attributes, :year => @year
    plan_after = Plan.find @plan.id
    assert_equal new_max_quantity, plan_after.max_quantity
    assert_redirected_to plans_path
  end

end
