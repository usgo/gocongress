require 'test_helper'

class EventsControllerTest < ActionController::TestCase
  setup do
    @activity = Factory(:event)
    @user = Factory.create(:user)
    @admin_user = Factory.create(:admin)
  end

  test "user cannot get new" do
    sign_in @user
    get :new, :year => Time.now.year
    assert_response 403
  end

  test "user cannot create activity" do
    sign_in @user
    post :create, :year => Time.now.year, :event => @activity.attributes
    assert_response 403
  end
  
  test "admin can create activity" do
    sign_in @admin_user
    assert @activity.valid?, "activity is not valid"
    assert_difference('Event.count') do
      post :create, :year => Time.now.year, :event => @activity.attributes
    end
    assert_redirected_to event_path(assigns(:event))
  end

  test "anyone can show activity" do
    get :show, :year => Time.now.year, :id => @activity.to_param
    assert_response :success
  end

end
