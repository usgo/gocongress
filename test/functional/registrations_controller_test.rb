require 'test_helper'

class RegistrationsControllerTest < ActionController::TestCase
  tests Devise::RegistrationsController

  test "sign up page displays" do
    get :new
    assert_response :success
  end

  test "valid registration data creates a new user" do
    assert_difference ["User.count", "Attendee.count"], +1 do
      post :create, :user => {"primary_attendee_attributes"=> {"birth_date(2i)"=>"1",
      "understand_minor"=>"0", "aga_id"=>"", "city"=>"Ithaca", "birth_date(3i)"=>"1",
      "zip"=>"12345", "country"=>"USA", "anonymous"=>"0", "gender"=>"m", "rank"=>"3",
      "family_name"=>"Beck", "address_1"=>"123 Fake St.", "phone"=>"", "address_2"=>"",
      "given_name"=>"Jared", "birth_date(1i)"=>"1891", "state"=>""}, "password_confirmation"=>"asdf", "password"=>"asdf", "email"=>"test120489@j.singlebrook.com"}
      puts assigns(:user).errors.full_messages
    end
    assert assigns(:user).primary_attendee.user_id.present?
    assert_response :redirect
  end

  test "invalid registration data does not create new user" do
    assert_no_difference ["User.count", "Attendee.count"] do
      post :create, :user => {}
    end
    assert_template "new"
  end
end
