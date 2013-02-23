require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  setup do
    pa = create :attendee, is_primary: true
    @user = pa.user
    @staff = create :staff
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
