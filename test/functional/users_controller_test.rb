require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  setup do
    pa = FactoryGirl.create :attendee, is_primary: true
    @user = pa.user
    @staff = FactoryGirl.create :staff
    @admin_user = FactoryGirl.create :admin
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

  test "guest cannot update user" do
    put :update, :id => @user.id, :user => @user.attributes, :year => Time.now.year
    assert_response 403
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
