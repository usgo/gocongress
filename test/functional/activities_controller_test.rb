require 'test_helper'

class ActivitiesControllerTest < ActionController::TestCase
  setup do
    @activity = FactoryGirl.create(:activity)
    @user = FactoryGirl.create(:user)
  end

  test "user cannot get new" do
    sign_in @user
    get :new, :year => Time.now.year
    assert_response 403
  end

  test "user cannot create activity" do
    sign_in @user
    post :create, :year => Time.now.year, :activity => @activity.attributes
    assert_response 403
  end

  test "anyone can show activity" do
    get :show, :year => Time.now.year, :id => @activity.to_param
    assert_response :success
  end

end
