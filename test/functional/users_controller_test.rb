require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  setup do
    @user = Factory.create(:user)
    @user_two = Factory.create(:user)
    @admin_user = Factory.create(:admin_user)
    @job = Factory.create(:job)
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
  
  test "visitors can not get edit" do
    get :edit, :id => @user.to_param
    assert_response 403
  end
  
  test "users can not edit other users" do
    sign_in @user
    get :edit, :id => @user_two.to_param
    assert_response 403
  end
  
  test "users can edit themselves" do
    sign_in @user
    get :edit, :id => @user.to_param
    assert_response :success
  end

  test "admin should update user" do
    sign_in @admin_user
    put :update, :id => @user.to_param, :user => @user.attributes
    assert_redirected_to users_path
  end
  
  test "visitor should NOT update user" do
    put :update, :id => @user.to_param, :user => @user.attributes
    assert_response 403
  end
  
  test "users can update themselves" do
    sign_in @user
    email_before = @user.email
    u = @user.attributes
    u['email'] = 'freeb@narf.com'
    put :update, :id => @user.to_param, :user => u
    @user = User.find(@user.id)
    assert_not_equal email_before, @user.email
    assert_redirected_to user_path(@user)
  end
  
  test "users can NOT promote themselves" do
    sign_in @user
    u = @user.attributes.merge({ 'is_admin' => true })
    assert_no_difference('@user.is_admin ? 1 : 0') do
      put :update, :id => @user.to_param, :user => u
    end
    assert_equal false, User.find(@user.id).is_admin
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
    destroyed_user_id = @user.id

    assert_difference('User.count', -1) do
      delete :destroy, :id => @user.to_param
    end

    assert_redirected_to users_path
    assert_equal 'User deleted', flash[:notice]

    # dependent attendees should also be destroyed
    assert_equal 0, Attendee.where(:user_id => destroyed_user_id).count
  end

  test "admin can assign jobs to any user" do
    sign_in @admin_user
    u = @user.attributes.merge({ 'job_ids' => [@job.id] })
    put :update, :id => @user.to_param, :user => u
    @user = User.find(@user.id)
    assert_equal @job.id, @user.jobs.first.id
  end

  test "user can NOT assign jobs even to themself" do
    sign_in @user

    # starting with zero jobs ..
    assert_equal 0, @user.jobs.size

    # mass assignment should NOT change job count
    u = @user.attributes.merge({ 'job_ids' => [@job.id] })
    assert_no_difference('@user.jobs.size') do
      put :update, :id => @user.to_param, :user => u
    end

    # reload user and double check that they have zero jobs
    @user = User.find(@user.id)
    assert_equal 0, @user.jobs.size
  end
end
