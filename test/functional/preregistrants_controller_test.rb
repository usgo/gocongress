require 'test_helper'

class PreregistrantsControllerTest < ActionController::TestCase
  setup do
    @user = Factory.create :user
    @staff = Factory.create :staff
    @admin = Factory.create :admin_user
  end

  test "admin can index preregistrants" do
    sign_in @admin
    get :index
    assert_response :success
  end

  test "staff can index preregistrants" do
    sign_in @staff
    get :index
    assert_response :success
  end

  test "user cannot index preregistrants" do
    sign_in @user
    get :index
    assert_response 403
  end

  test "guest cannot index preregistrants" do
    get :index
    assert_response 403
  end  

end
