require 'test_helper'

class PlansControllerTest < ActionController::TestCase
  setup do
    @plan = Factory.create(:plan)
    @user = Factory.create(:user)
    @admin_user = Factory.create(:admin_user)
  end

  test "anybody can get index" do
    get :index
    assert_response :success
  end

  test "non-admin should NOT get new" do
    sign_in @user
    get :new
    assert_response 403
  end

  test "non-admin can NOT create plan" do
    sign_in @user
    post :create, :plan => @plan.attributes
    assert_response 403
  end
  
  test "admin can create plan" do
    sign_in @admin_user
    assert_difference('Plan.count') do
      post :create, :plan => @plan.attributes
    end
    assert_redirected_to plans_path
  end

  test "non-admin can NOT show plan" do
  	sign_in @user
    get :show, :id => @plan.to_param
    assert_response 403
  end

end
