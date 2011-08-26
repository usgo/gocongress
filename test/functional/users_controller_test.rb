require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  setup do
    @user = Factory.create(:user)
    @user_two = Factory.create(:user)
    @staff = Factory.create(:staff)
    @admin_user = Factory.create(:admin_user)
    @job = Factory.create(:job)
  end

  test "admin can get index" do
    sign_in @admin_user
    get :index
    assert_response :success
  end
  
  test "staff can get index" do
    sign_in @staff
    get :index
    assert_response :success
  end

  test "admin can get user cost summary" do
    sign_in @admin_user
    get :print_cost_summary, :id => @user.id
    assert_response :success
  end

  test "staff can get user cost summary" do
    sign_in @staff
    get :print_cost_summary, :id => @user.id
    assert_response :success
  end

  test "user cannot get user cost summary" do
    sign_in @user
    get :print_cost_summary, :id => @user.id
    assert_response 403
  end

  test "user cannot get index" do
    sign_in @user
    get :index
    assert_response 403
  end
  
  test "guest cannot get index" do
    get :index
    assert_response 403
  end

  test "admin can show user" do
    sign_in @admin_user
    get :show, :id => @user.to_param
    assert_response :success
  end

  test "staff can show user" do
    sign_in @staff
    get :show, :id => @user.to_param
    assert_response :success
  end
  
  test "guest cannot show user" do
    get :show, :id => @user.to_param
    assert_response 403
  end

  test "user can show self" do
    sign_in @user
    get :show, :id => @user.id
    assert_response :success
  end

  test "staff can show self" do
    sign_in @staff
    get :show, :id => @staff.id
    assert_response :success
  end

  test "user cannot show a different user" do
    sign_in @user
    get :show, :id => Factory.create(:user).to_param
    assert_response 403
  end

  test "admin can get edit" do
    sign_in @admin_user
    get :edit, :id => @user.to_param
    assert_response :success
  end
  
  test "guest cannot get edit" do
    get :edit, :id => @user.to_param
    assert_response 403
  end
  
  test "user cannot edit other user" do
    sign_in @user
    get :edit, :id => @user_two.to_param
    assert_response 403
  end

  test "staff cannot edit other user" do
    sign_in @staff
    get :edit, :id => @user.to_param
    assert_response 403
  end
  
  test "user cannot edit themselves" do
    sign_in @user
    get :edit, :id => @user.to_param
    assert_response 403
  end

  test "staff cannot edit themselves" do
    sign_in @staff
    get :edit, :id => @staff.to_param
    assert_response 403
  end

  test "admin can update user" do
    sign_in @admin_user
    put :update, :id => @user.to_param, :user => @user.attributes
    assert_redirected_to user_path(@user)
  end
  
  test "guest cannot update user" do
    put :update, :id => @user.to_param, :user => @user.attributes
    assert_response 403
  end
  
  test "user can update own email address" do
    sign_in @user
    email_before = @user.email

    # define a new email that is different from the old one
    new_email_addy = 'freeb@narf.com'
    assert_not_equal new_email_addy, @user.email

    # put to update
    u = @user.attributes.merge({ 'email' => new_email_addy })
    put :update, :id => @user.id, :user => u
    
    # assert that email changed
    @user = User.find(@user.id)
    assert_not_equal email_before, @user.email
  end
  
  test "staff can update own email address" do
    sign_in @staff
    email_before = @staff.email

    # define a new email that is different from the old one
    new_email_addy = 'freeb@narf.com'
    assert_not_equal new_email_addy, @staff.email

    # put to update
    u = @staff.attributes.merge({ 'email' => new_email_addy })
    put :update, :id => @staff.id, :user => u
    
    # assert that email changed
    @staff = User.find(@staff.id)
    assert_not_equal email_before, @staff.email
  end
  
  test "staff can get edit email form" do
    sign_in @staff
    get :edit_email, :id => @staff.id
    assert_response :success
  end
  
  test "user can get edit password form" do
    sign_in @user
    get :edit_password, :id => @user.id
    assert_response :success
  end
  
  test "user cannot promote themselves" do
    sign_in @user
    assert_equal 'U', @user.role
    u = @user.attributes.merge({ 'role' => 'A' })
    assert_no_difference('User.find(@user.id).is_admin? ? 1 : 0') do
      put :update, :id => @user.id, :user => u
    end
    assert_equal 'U', User.find(@user.id).role
  end

  test "user cannot destroy self" do
    sign_in @user
    assert_no_difference('User.count') do
      delete :destroy, :id => @user.id
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

  test "user cannot assign jobs even to themself" do
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

  test "admin can change a user password" do
    sign_in @admin_user
    enc_pw_before = @user.encrypted_password
    u = { 'password' => 'greeblesnarf' }
    put :update, :id => @user.to_param, :user => u
    
    # re-load the user to see if the encrypted_password changed
    @user = User.find @user.id
    assert_not_equal @user.encrypted_password, enc_pw_before
  end

end
