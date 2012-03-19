require 'test_helper'

class RegistrationsControllerTest < ActionController::TestCase
  tests RegistrationsController

  setup do
    @year = Time.now.year
    @u = Factory.attributes_for(:user)
    @u.merge!({ :primary_attendee_attributes => Factory.attributes_for(:attendee) })
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

  # TODO: This test is defunct.  When we drop accepts_nested_attributes_for
  # from the User model, this test will be removed (or rewritten).
  test "visitor can create a user with valid registration data" do
    assert_difference ["User.count", "Attendee.count"], +1 do
      post :create, :user => @u, :year => @year
    end
    assert assigns(:user).primary_attendee.user_id.present?
    assert assigns(:user).primary_attendee.is_primary?
    assert_response :redirect
  end

  test "visitor cannot create a user with invalid registration data" do
    assert_no_difference ["User.count", "Attendee.count"] do
      post :create, :user => {}, :year => @year
    end
    assert_template "new"
  end

  test "visitor cannot specify role" do
    @u[:role] = 'A' # A for admin
    post :create, :user => @u, :year => @year

    # we expect the user to be created, but the specified role to be ignored
    assert_response :redirect
    assert assigns(:user).role == 'U'
  end

  test "minor agreement validator" do

    # Our visitor is a minor, but did not click the "understand" checkbox
    @u[:primary_attendee_attributes][:birth_date] = 5.years.ago
    @u[:primary_attendee_attributes][:understand_minor] = 0

    assert_no_difference ["User.count", "Attendee.count"] do
      post :create, :user => @u, :year => @year
    end
    assert_template "new"
    assert_equal false, assigns(:user).errors.empty?
    assert assigns(:user).errors.include?(:"primary_attendee.liability_release")
  end
end
