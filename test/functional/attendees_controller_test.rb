require 'test_helper'

class AttendeesControllerTest < ActionController::TestCase
  setup do
    @attendee = Factory.create(:attendee)
    @user = Factory.create(:user)
    @user_two = Factory.create(:user)
    @admin_user = Factory.create(:admin_user)
  end

  test "visitor can get index" do
    get :index
    assert_response :success
  end

  test "non-admin can NOT destroy an attendee" do
    sign_in @user
    assert_difference('Attendee.count', 0) do
      delete :destroy, :id => @attendee.to_param
    end
    assert_response 403
  end

  test "admin can destroy an attendee" do
    sign_in @admin_user
    assert_difference('Attendee.count', -1) do
      delete :destroy, :id => @attendee.to_param
    end
    assert_redirected_to attendees_path
  end

  test "visitor can not get edit" do
    get :edit, :id => @attendee.to_param
    assert_response 403
  end

  test "user can not edit another user's attendee" do
    sign_in @user
    get :edit, :id => @attendee.to_param
    assert_response 403
  end

  test "user can edit their own attendees" do
    sign_in @user
    get :edit, :id => @user.attendees.first.to_param
    assert_response :success
  end

  test "admin can edit any attendee" do
    sign_in @admin_user
    get :edit, :id => @attendee.to_param
    assert_response :success
    get :edit, :id => @user.attendees.last.to_param
    assert_response :success
    get :edit, :id => @admin_user.attendees.first.to_param
    assert_response :success
  end

  test "user can not update another user's attendee" do
    sign_in @user
    target_attendee = @user_two.attendees.first
    target_attendee.state = 'NY'
    put :update, :id => target_attendee.id, :attendee => target_attendee.attributes
    assert_response 403
  end

  test "admin can update any user's attendee" do
    sign_in @admin_user

    target_attendee = @user.attendees.last
    target_attendee.state = 'MI'
    put :update, :id => target_attendee.id, :attendee => target_attendee.attributes
    assert_redirected_to user_path(target_attendee.user_id)

    target_attendee = @user_two.attendees.first
    target_attendee.state = 'AK'
    put :update, :id => target_attendee.id, :attendee => target_attendee.attributes
    assert_redirected_to user_path(target_attendee.user_id)
  end

  test "nobody can ever delete a primary attendee" do
    sign_in @admin_user
    assert_difference('Attendee.count', 0) do
      delete :destroy, :id => @admin_user.primary_attendee.to_param
    end
    assert_response 403
  end

  %w[basics baduk roomboard].each do |page|
    define_method "test_user_can_get_#{page}" do
      sign_in @user
      get :edit, :id => @user.attendees.sample.to_param, :page => page
      view_name = @controller.send( :get_view_name_from_page, page )
      assert_template view_name
    end

    define_method "test_vistor_can_not_get_#{page}" do
      get :edit, :id => @admin_user.attendees.sample.to_param, :page => page
      view_name = @controller.send( :get_view_name_from_page, page )
      assert_response 403
    end
  end

end
