require 'test_helper'

class EventsControllerTest < ActionController::TestCase
  setup do
    @event = Factory(:event)
    @user = Factory.create(:user)
    @admin_user = Factory.create(:admin_user)
  end

  test "anybody can get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:events)
  end

  test "user cannot get new" do
    sign_in @user
    get :new
    assert_response 403
  end

  test "user cannot create event" do
    sign_in @user
    post :create, :event => @event.attributes
    assert_response 403
  end
  
  test "admin can create event" do
    sign_in @admin_user
    assert @event.valid?, "event is not valid"
    assert_difference('Event.count') do
      post :create, :event => @event.attributes
    end
    assert_redirected_to event_path(assigns(:event))
  end

  test "anyone can show event" do
    get :show, :id => @event.to_param
    assert_response :success
  end

end
