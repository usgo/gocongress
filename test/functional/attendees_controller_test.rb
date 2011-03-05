require 'test_helper'

class AttendeesControllerTest < ActionController::TestCase
  setup do
    @attendee = Factory.create(:attendee)
    @user = Factory.create(:user)
    @user_two = Factory.create(:user)
    @admin_user = Factory.create(:admin_user)
    @plan = Factory.create(:plan)
  end

  test "visitor can get index" do
    get :index
    assert_response :success
  end

  test "visitor can not get new form" do
    get :new
    assert_response 403
  end

  test "visitor can not create attendee" do
    assert_no_difference('Attendee.count', 0) do
      post :create, :attendee => Factory.attributes_for(:attendee)
    end
    assert_response 403
  end

  test "user can not create attendee under a different user" do
    sign_in @user
    a = Factory.attributes_for(:attendee)
    a['user_id'] = @user_two.id
    assert_no_difference('Attendee.count', 0) do
      post :create, :attendee => a
    end
    assert_response 403
  end

  test "user can create attendee under own account" do
    sign_in @user
    a = Factory.attributes_for(:attendee)
    a['user_id'] = @user.id
    assert_difference('Attendee.where(:user_id => @user.id).count', +1) do
      post :create, :attendee => a
    end
  end

  test "non-admin can destroy own non-primary attendee" do
    sign_in @user
    a = Factory(:attendee, :user_id => @user.id)
    @user.save
    assert_equal 1, @user.attendees.where(:is_primary => false).count
    assert_difference('Attendee.count', -1) do
      delete :destroy, :id => a.id
    end
    assert_equal 0, @user.attendees.where(:is_primary => false).count
    assert_redirected_to user_path(@user)
  end

  test "non-admin can NOT destroy any primary attendee" do
    sign_in @user
    assert_no_difference('Attendee.count') do
      delete :destroy, :id => @user.primary_attendee.to_param
    end
    assert_response 403
  end

  test "non-admin can NOT destroy attendee from other user" do
    sign_in @user
    a = Factory(:attendee)
    @user_two.attendees << a
    @user_two.save
    assert_equal 1, @user_two.attendees.where(:is_primary => false).count
    assert_no_difference('Attendee.count') do
      delete :destroy, :id => a.id
    end
    assert_response 403
  end

  test "admin can destroy attendee" do
    sign_in @admin_user
    assert_difference('Attendee.count', -1) do
      delete :destroy, :id => @attendee.to_param
    end
    assert_redirected_to users_path
    assert_equal 'Attendee deleted', flash[:notice]
  end

  test "admin can destroy primary attendee" do
    sign_in @admin_user
    assert_equal 1, @user.attendees.where(:is_primary => true).count
    assert_difference('Attendee.count', -1) do
      delete :destroy, :id => @user.primary_attendee.to_param
    end
    assert_redirected_to users_path
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
    assert_equal 'Attendee successfully updated', flash[:notice]

    target_attendee = @user_two.attendees.first
    target_attendee.state = 'AK'
    put :update, :id => target_attendee.id, :attendee => target_attendee.attributes
    assert_redirected_to user_path(target_attendee.user_id)
    assert_equal 'Attendee successfully updated', flash[:notice]
  end

  %w[basics baduk roomboard].each do |page|
    define_method "test_user_can_get_#{page}" do
      sign_in @user
      get :edit, :id => @user.attendees.sample.to_param, :page => page
      view_name = @controller.send( :get_view_name_from_page, page )
      assert_response :success
      assert_template view_name
    end

    define_method "test_vistor_can_not_get_#{page}" do
      get :edit, :id => @admin_user.attendees.sample.to_param, :page => page
      view_name = @controller.send( :get_view_name_from_page, page )
      assert_response 403
    end
  end

	test "user can select a plan for their own attendee" do
    sign_in @user
    assert_equal(true, Plan.count > 0)	# there are plans
    random_attendee = @user.attendees.sample # get random attendee
    assert_equal(0, random_attendee.plans.count) # attendee has zero plans

    # prepare attribute hash for submission
    h = random_attendee.attributes.to_hash
    h.merge!(:plan_ids => Plan.all.sample.to_param)

    # put to update
    assert_difference('random_attendee.plans.count', +1) do
      put :update, :id => random_attendee.to_param, :attendee => h
    end
    assert_redirected_to user_path(@user.to_param)
	end

end
