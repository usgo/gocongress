require 'test_helper'

class ReportsControllerTest < ActionController::TestCase
  setup do
    @user = Factory.create(:user)
    @staff = Factory.create(:staff)
    @admin = Factory.create(:admin_user)
  end

  test "admin can get overdue_deposits csv export" do
    sign_in @admin
    get :overdue_deposits, :format => 'csv'
    assert_response :success
  end

  test "staff can get attendees report" do
    sign_in @staff
    get :attendees, :format => 'csv'
    assert_response :success
  end

  test "user cannot get attendees report" do
    sign_in @user
    get :attendees, :format => 'csv'
    assert_response 403
  end

end
