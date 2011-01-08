require 'test_helper'

class AttendeesControllerTest < ActionController::TestCase
  setup do
  	@attendee = Factory.create(:attendee)
    @user = Factory.create(:user)
    @admin_user = Factory.create(:admin_user)
  end

  test "visitor can get index" do
    get :index
    assert_response :success
  end

  test "non-admin can NOT destroy an attendee" do
    sign_in @user
    assert_difference('Attendee.count', 0) do
      delete :destroy, :id => @attendee.to_param
    end
    assert_response 403
  end

  test "admin can destroy an attendee" do
    sign_in @admin_user
    assert_difference('Attendee.count', -1) do
      delete :destroy, :id => @attendee.to_param
    end
    assert_redirected_to attendees_path
  end
end
