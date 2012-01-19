require 'test_helper'

class DevisePasswordsControllerTest < ActionController::TestCase
  setup do
    @controller = Devise::PasswordsController.new
    @user = Factory :user
    @year = Time.now.year
  end

  test "user can create reset password token" do
    post :create, :user => {:email => @user.email}, :year => @year
    assert_response :success
  end
end
