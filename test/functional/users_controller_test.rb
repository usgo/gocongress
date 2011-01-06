require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  setup do
    @user = Factory.create(:user)
    @admin_user = Factory.create(:admin_user)
  end

  test "admins should get index" do
    sign_in @admin_user
    get :index
    assert_response :success
  end
  
  test "non-admins should NOT get index" do
    get :index
    assert_response 403
  end

  test "admins should show user" do
    sign_in @admin_user
    get :show, :id => @user.to_param
    assert_response :success
  end
  
  test "visitors should NOT show user" do
    get :show, :id => @user.to_param
    assert_response 403
  end

  test "users can show their own user" do
    sign_in @user
    get :show, :id => @user.to_param
    assert_response :success
  end

  test "users should NOT show a different user" do
    sign_in @user
    get :show, :id => Factory.create(:user).to_param
    assert_response 403
  end

  test "admins can get edit" do
    sign_in @admin_user
    get :edit, :id => @user.to_param
    assert_response :success
  end
  
  test "non-admins can not get edit" do
    get :edit, :id => @user.to_param
    assert_response 403
  end

  test "admin should update user" do
    sign_in @admin_user
    put :update, :id => @user.to_param, :user => @user.attributes
    assert_redirected_to users_path
  end
  
  test "non-admin should NOT update user" do
    put :update, :id => @user.to_param, :user => @user.attributes
    assert_response 403
  end

  test "non-admin cannot destroy a user" do
    sign_in @user

    assert_difference('User.count', 0) do
      delete :destroy, :id => @user.to_param
    end

    assert_response 403
  end

  test "admin can destroy a user" do
    sign_in @admin_user

    assert_difference('User.count', -1) do
      delete :destroy, :id => @user.to_param
    end

    assert_redirected_to users_path
  end
end
