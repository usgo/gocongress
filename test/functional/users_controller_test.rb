require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  setup do
    pa = create :attendee, is_primary: true
    @user = pa.user
    @staff = create :staff
  end

  test "user cannot edit other user" do
    sign_in @user
    user_two = create(:user)
    get :edit, :id => user_two.id, :year => Time.now.year
    assert_response 403
  end

  test "staff cannot edit other user" do
    sign_in @staff
    get :edit, :id => @user.id, :year => Time.now.year
    assert_response 403
  end

  test "user cannot edit themselves" do
    sign_in @user
    get :edit, :id => @user.id, :year => Time.now.year
    assert_response 403
  end

  test "staff cannot edit themselves" do
    sign_in @staff
    get :edit, :id => @staff.id, :year => Time.now.year
    assert_response 403
  end

  test "staff can get edit email form" do
    sign_in @staff
    get :edit_email, :id => @staff.id, :year => Time.now.year
    assert_response :success
  end

  test "user can get edit password form" do
    sign_in @user
    get :edit_password, :id => @user.id, :year => Time.now.year
    assert_response :success
  end

  test "user cannot destroy self" do
    sign_in @user
    assert_no_difference('User.count') do
      delete :destroy, :id => @user.id, :year => Time.now.year
    end
    assert_response 403
  end

  test "admin can destroy a user" do
    sign_in create :admin
    destroyed_user_id = @user.id

    assert_difference('User.count', -1) do
      delete :destroy, :id => @user.to_param, :year => Time.now.year
    end

    assert_redirected_to users_path
    assert_equal 'User deleted', flash[:notice]

    # dependent attendees should also be destroyed
    assert_equal 0, Attendee.where(:user_id => destroyed_user_id).count
  end

end
