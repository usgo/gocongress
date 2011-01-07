require 'test_helper'

class RegistrationsControllerTest < ActionController::TestCase
  tests Devise::RegistrationsController

  test "sign up page displays" do
    get :new
    assert_response :success
  end

  test "valid registration data creates a new user" do

    # using our user factory, prepare a user hash that mimics what the 
    # params would look like on a valid create request -Jared
    a = { :primary_attendee_attributes => Factory.attributes_for(:attendee) }
    u = Factory.attributes_for(:user).merge( a )
    
    assert_difference ["User.count", "Attendee.count"], +1 do
      post :create, :user => u
      puts assigns(:user).errors.full_messages
    end
    assert assigns(:user).primary_attendee.user_id.present?
    assert assigns(:user).primary_attendee.is_primary?
    assert_response :redirect
  end

  test "invalid registration data does not create new user" do
    assert_no_difference ["User.count", "Attendee.count"] do
      post :create, :user => {}
    end
    assert_template "new"
  end
end
