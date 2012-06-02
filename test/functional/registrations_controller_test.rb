require 'test_helper'

class RegistrationsControllerTest < ActionController::TestCase
  tests RegistrationsController

  setup do
    @year = Time.now.year
    @u = FactoryGirl.attributes_for(:user)
  end

  test "visitor can get sign up page" do
    get :new, :year => @year
    assert_response :success
  end

  test "visitor can create a user with valid email and password" do
    user_attrs = { email: 'example@example.com',
      password: 'asdf',
      password_confirmation: 'asdf',
      year: @year }
    assert_difference ["User.count"], +1 do
      post :create, :user => user_attrs, :year => @year
    end
    created_user = User.yr(@year).order(:created_at).last
    assert_redirected_to add_attendee_to_user_path(@year, created_user.id)
  end

  test "visitor cannot specify role" do
    @u[:role] = 'A' # A for admin
    post :create, :user => @u, :year => @year

    # we expect the user to be created, but the specified role to be ignored
    assert_response :redirect
    assert assigns(:user).role == 'U'
  end
end
