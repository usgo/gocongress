require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  setup do
    @user = FactoryGirl.create :user
    @staff = FactoryGirl.create :staff
    @admin_user = FactoryGirl.create :admin
  end

  test "admin cannot read user from different year" do
    a = FactoryGirl.create :admin, year: 2011
    u = FactoryGirl.create :user, year: 2012
    sign_in a
    assert_raise(ActiveRecord::RecordNotFound) {
      get :show, :id => u.id, :year => a.year
    }
  end

  test "staff cannot read user from different year" do
    s = FactoryGirl.create :staff, year: 2011
    u = FactoryGirl.create :user, year: 2012
    sign_in s
    assert_raise(ActiveRecord::RecordNotFound) {
      get :show, :id => u.id, :year => s.year
    }
  end

  test "admin can get index" do
    sign_in @admin_user
    get :index, :year => Time.now.year
    assert_response :success
  end

  test "staff can get index" do
    sign_in @staff
    get :index, :year => Time.now.year
    assert_response :success
  end

  test "admin can get user cost summary" do
    sign_in @admin_user
    get :print_cost_summary, :id => @user.id, :year => Time.now.year
    assert_response :success
  end

  test "staff can get user cost summary" do
    sign_in @staff
    get :print_cost_summary, :id => @user.id, :year => Time.now.year
    assert_response :success
  end

  test "user cannot get user cost summary" do
    sign_in @user
    get :print_cost_summary, :id => @user.id, :year => Time.now.year
    assert_response 403
  end

  test "user cannot get index" do
    sign_in @user
    get :index, :year => Time.now.year
    assert_response 403
  end

  test "guest cannot get index" do
    get :index, :year => Time.now.year
    assert_response 403
  end

  test "admin can show user from same year" do
    sign_in @admin_user
    get :show, :id => @user.to_param, :year => Time.now.year
    assert_response :success
  end

  test "staff can show user from same year" do
    sign_in @staff
    get :show, :id => @user.to_param, :year => Time.now.year
    assert_response :success
  end

  test "guest cannot show user" do
    get :show, :id => @user.to_param, :year => Time.now.year
    assert_response 403
  end

  test "user can show self" do
    sign_in @user
    get :show, :id => @user.id, :year => Time.now.year
    assert_response :success
  end

  test "staff can show self" do
    sign_in @staff
    get :show, :id => @staff.id, :year => Time.now.year
    assert_response :success
  end

  test "user cannot show a different user" do
    sign_in @user
    get :show, :id => FactoryGirl.create(:user).id, :year => Time.now.year
    assert_response 403
  end

  test "admin can get edit" do
    sign_in @admin_user
    get :edit, :id => @user.id, :year => Time.now.year
    assert_response :success
  end

  test "guest cannot get edit" do
    get :edit, :id => @user.id, :year => Time.now.year
    assert_response 403
  end

  test "user cannot edit other user" do
    sign_in @user
    user_two = FactoryGirl.create(:user)
    get :edit, :id => user_two.id, :year => Time.now.year
    assert_response 403
  end

  test "staff cannot edit other user" do
    sign_in @staff
    get :edit, :id => @user.id, :year => Time.now.year
    assert_response 403
  end

  test "user cannot edit themselves" do
    sign_in @user
    get :edit, :id => @user.id, :year => Time.now.year
    assert_response 403
  end

  test "staff cannot edit themselves" do
    sign_in @staff
    get :edit, :id => @staff.id, :year => Time.now.year
    assert_response 403
  end

  test "admin can update user" do
    sign_in @admin_user
    put :update, :id => @user.id, :user => @user.attributes, :year => Time.now.year
    assert_redirected_to user_path(@user)
  end

  test "guest cannot update user" do
    put :update, :id => @user.id, :user => @user.attributes, :year => Time.now.year
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
    put :update, :id => @user.id, :user => u, :year => Time.now.year

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
    put :update, :id => @staff.id, :user => u, :year => Time.now.year

    # assert that email changed
    @staff = User.find(@staff.id)
    assert_not_equal email_before, @staff.email
  end

  test "staff can get edit email form" do
    sign_in @staff
    get :edit_email, :id => @staff.id, :year => Time.now.year
    assert_response :success
  end

  test "user can get edit password form" do
    sign_in @user
    get :edit_password, :id => @user.id, :year => Time.now.year
    assert_response :success
  end

  test "user cannot promote themselves" do
    sign_in @user
    assert_equal 'U', @user.role
    u = @user.attributes.merge({ 'role' => 'A' })
    assert_no_difference('User.find(@user.id).is_admin? ? 1 : 0') do
      put :update, :id => @user.id, :user => u, :year => Time.now.year
    end
    assert_equal 'U', User.find(@user.id).role
  end

  test "user cannot destroy self" do
    sign_in @user
    assert_no_difference('User.count') do
      delete :destroy, :id => @user.id, :year => Time.now.year
    end
    assert_response 403
  end

  test "admin can destroy a user" do
    sign_in @admin_user
    destroyed_user_id = @user.id

    assert_difference('User.count', -1) do
      delete :destroy, :id => @user.to_param, :year => Time.now.year
    end

    assert_redirected_to users_path
    assert_equal 'User deleted', flash[:notice]

    # dependent attendees should also be destroyed
    assert_equal 0, Attendee.where(:user_id => destroyed_user_id).count
  end

  test "admin can assign jobs to any user" do
    sign_in @admin_user
    job = FactoryGirl.create(:job)
    u = @user.attributes.merge({ 'job_ids' => [job.id] })
    put :update, :id => @user.to_param, :user => u, :year => Time.now.year
    @user = User.find(@user.id)
    assert_equal job.id, @user.jobs.first.id
  end

  test "user cannot assign jobs even to themself" do
    sign_in @user
    job = FactoryGirl.create(:job)

    # starting with zero jobs assigned ..
    assert_equal 0, @user.jobs.size

    # mass assignment should NOT change job count
    u = @user.attributes.merge({ 'job_ids' => [job.id] })
    assert_no_difference('@user.jobs.size') do
      put :update, :id => @user.id, :user => u, :year => Time.now.year
    end

    # reload user and double check that they have zero jobs
    @user = User.find(@user.id)
    assert_equal 0, @user.jobs.size
  end

  test "admin can change a user password" do
    sign_in @admin_user
    enc_pw_before = @user.encrypted_password
    u = { 'password' => 'greeblesnarf' }
    put :update, :id => @user.id, :user => u, :year => Time.now.year

    # re-load the user to see if the encrypted_password changed
    @user = User.find @user.id
    assert_not_equal @user.encrypted_password, enc_pw_before
  end

  test "admin cannot update user year" do
    sign_in @admin_user
    year_before = @user.year
    u = { 'year' => @user.year + 1 }
    put :update, :id => @user.id, :user => u, :year => @user.year
    @user.reload
    assert_equal year_before, @user.year
  end

end
