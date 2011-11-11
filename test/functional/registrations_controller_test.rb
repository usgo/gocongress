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
  
  test "minor agreement validator" do
    a = Factory.attributes_for(:attendee)
    a[:birth_date] = 5.years.ago # definitely a minor
    a[:understand_minor] = 0 # did not click "understand" checkbox
    u = Factory.attributes_for(:user).merge( { :primary_attendee_attributes => a } )

    assert_no_difference ["User.count", "Attendee.count"] do
      post :create, :user => u
    end
    assert_template "new"
    assert_equal false, assigns(:user).errors.empty?
    assert assigns(:user).errors.include?(:"primary_attendee.understand_minor")
  end
end
