require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  setup do
    @user = users(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:users)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create user" do
    @user.destroy

    assert_difference('User.count', 1) do
      post :create, :user => @user.attributes.merge(:password => 'password')
    end

    assert_redirected_to users_path
  end

  test "won't create a user without a password" do
    @user.destroy

    assert_difference('User.count', 0) do
      post :create, :user => @user.attributes
    end

    assert_tag :div, :attributes => {:id => 'error_explanation'}, :child => "Password can't be blank"
  end

  test "should show user" do
    get :show, :id => @user.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @user.to_param
    assert_response :success
  end

  test "should update user" do
    put :update, :id => @user.to_param, :user => @user.attributes
    assert_redirected_to users_path
  end

  test "non-admin cannot destroy a user" do
    sign_in(:user, users(:two))

    assert_difference('User.count', 0) do
      delete :destroy, :id => @user.to_param
    end

    assert_redirected_to users_path
  end

  test "admin can destroy a user" do
    sign_in(:user, users(:admin))

    assert_difference('User.count', -1) do
      delete :destroy, :id => @user.to_param
    end

    assert_redirected_to users_path
  end
end
