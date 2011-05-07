require 'test_helper'

class PlansControllerTest < ActionController::TestCase
  setup do
    @plan = Factory.create(:plan)
    @user = Factory.create(:user)
    @admin_user = Factory.create(:admin_user)
  end

  test "visitors can get roomboard page" do
    get :room_and_board
    assert_response :success
  end

  test "visitors can get prices and extras page" do
    get :prices_and_extras
    assert_response :success
  end

  test "visitors cannot get index" do
    get :index
    assert_response 403
  end

  test "admins can get index" do
    sign_in @admin_user
    get :index
    assert_response :success
  end

  test "non-admin should NOT get new" do
    sign_in @user
    get :new
    assert_response 403
  end

  test "non-admin cannot create plan" do
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

  test "non-admin cannot show plan" do
  	sign_in @user
    get :show, :id => @plan.to_param
    assert_response 403
  end

end
