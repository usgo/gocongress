require 'test_helper'

class RegistrationsControllerTest < ActionController::TestCase
  tests RegistrationsController

  setup do
    @year = Time.now.year
  end

  test "visitor can get sign up page" do
    get :new, :year => @year
    assert_response :success
  end

  test "visitor can create a user with valid email and password" do
    user_attrs = { email: 'example@example.com',
      password: 'asdfasdf',
      password_confirmation: 'asdfasdf',
      year: @year }
    assert_difference ["User.count"], +1 do
      post :create, :user => user_attrs, :year => @year
    end
    created_user = User.yr(@year).order(:created_at).last
    assert_redirected_to new_attendee_path(@year)
  end
end
