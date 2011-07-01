require 'test_helper'

class ReportsControllerTest < ActionController::TestCase
  setup do
    @user = Factory.create(:user)
    @admin = Factory.create(:admin_user)
  end

  test "admin can get overdue_deposits csv export" do
    sign_in @admin
    get :overdue_deposits, :format => 'csv'
    assert_response :success
  end
end
