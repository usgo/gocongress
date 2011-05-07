require 'test_helper'

class AttendeesControllerTest < ActionController::TestCase
  setup do
    @attendee = Factory.create(:attendee)
    @user = Factory.create(:user)
    @user_two = Factory.create(:user)
    @admin_user = Factory.create(:admin_user)
    @plan = Factory.create(:all_ages_plan)
    @discount_automatic = Factory.create(:automatic_discount)
    @discount_nonautomatic = Factory.create(:nonautomatic_discount)
    @discount_nonautomatic2 = Factory.create(:nonautomatic_discount)
  end

  test "visitor can get index" do
    get :index
    assert_response :success
  end

  test "visitor cannot get new form" do
    get :new
    assert_response 403
  end

  test "visitor cannot create attendee" do
    assert_no_difference('Attendee.count', 0) do
      post :create, :attendee => Factory.attributes_for(:attendee)
    end
    assert_response 403
  end

  test "user cannot create attendee under a different user" do
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

  test "non-admin cannot destroy any primary attendee" do
    sign_in @user
    assert_no_difference('Attendee.count') do
      delete :destroy, :id => @user.primary_attendee.to_param
    end
    assert_response 403
  end

  test "non-admin cannot destroy attendee from other user" do
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
    assert_redirected_to user_path(@attendee.user)
    assert_equal 'Attendee deleted', flash[:notice]
  end

  test "admin can destroy primary attendee" do
    sign_in @admin_user
    assert_equal 1, @user.attendees.where(:is_primary => true).count
    assert_difference('Attendee.count', -1) do
      delete :destroy, :id => @user.primary_attendee.to_param
    end
    assert_redirected_to user_path(@user)
  end

  test "visitor cannot get edit" do
    get :edit, :id => @attendee.to_param
    assert_response 403
  end

  test "user cannot edit another user's attendee" do
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

  test "user cannot update another user's attendee" do
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
    random_attendee = @user.attendees.sample
    assert_equal(0, random_attendee.plans.count)

    # prepare attribute hash for submission
    h = random_attendee.attributes.to_hash
    h.merge!(:plan_ids => Plan.all.sample.to_param)

    # put to update
    assert_difference('random_attendee.plans.count', +1) do
      put :update, :id => random_attendee.to_param, :attendee => h
    end
    assert_redirected_to user_path(@user.to_param)
	end

  test "user cannot select plan for attendee belonging to someone else" do
    sign_in @user
    a = @user_two.attendees.sample

    # prepare attribute hash for submission
    h = a.attributes.to_hash
    h.merge!(:plan_ids => Plan.all.sample.to_param)

    # put to update
    assert_no_difference('a.plans.count') do
      put :update, :id => a.to_param, :attendee => h
    end
    assert_response 403
  end

  test "admin can select plan for attendee belonging to someone else" do
    sign_in @admin_user
    a = @user.attendees.sample
    assert_equal(0, a.plans.count)
    h = a.attributes.to_hash
    h[:plan_ids] = @plan.to_param
    assert_difference('a.plans.count', +1) do
      put :update, :id => a.to_param, :attendee => h
    end
    assert_redirected_to user_path(@user.to_param)
  end

	test "user can clear own attendee plans" do
    sign_in @user
    a = @user.attendees.sample
    a.plans << @plan
    assert_equal(1, a.plans.count)

    # prepare attribute hash for submission
    h = a.attributes.to_hash
    h[:plan_ids] = ''

    # put to update
    assert_difference('a.plans.count', -1) do
      put :update, :id => a.to_param, :attendee => h
    end
    assert_equal(0, a.plans.count)
    assert_redirected_to user_path(@user.to_param)
	end

	test "edit form contains hidden plan_ids input even if attendee has zero plans" do
    sign_in @user
    a = @user.attendees.sample
    assert(Plan.appropriate_for_age(a.age_in_years).count > 0)
    assert_equal(0, a.plans.count)
    get :edit, :page => "roomboard", :id => a.to_param
    assert_tag({ :tag => "input", :attributes => { :name => "attendee[plan_ids][]", :type => "hidden" }})
	end

  test "admin can update deposit_received_at" do
    sign_in @admin_user

    # pick a random attendee
    a = @user.attendees.sample

    # make sure that deposit_received_at is nil,
    # so we can tell later that we have changed it.
    a.deposit_received_at = nil
    a.save
    a = Attendee.find(a.id)
    assert_equal nil, a.deposit_received_at

    # prepare the params for update
    atn_atr_hash = {}
    new_date = Time.now.to_date
    atn_atr_hash["deposit_received_at(1i)"] = new_date.year
    atn_atr_hash["deposit_received_at(2i)"] = new_date.month
    atn_atr_hash["deposit_received_at(3i)"] = new_date.day

    # perform update
    put :update, { :id => a.id, :attendee => atn_atr_hash, :page => 'admin' }

    # assert that deposit_received_at has been updated
    a = Attendee.find(a.id)
    assert_equal new_date, a.deposit_received_at

    # PUTing a date with any missing fields should clear the date entirely
    atn_atr_hash = {}
    atn_atr_hash["deposit_received_at(3i)"] = ""
    put :update, { :id => a.id, :attendee => atn_atr_hash, :page => 'admin' }
    a = Attendee.find(a.id)
    assert_equal nil, a.deposit_received_at
  end

  test "non-admin can claim non-automatic discounts" do
    sign_in @user
    a = @user.attendees.sample
    assert_equal 0, a.discounts.count
    atn_attrs = {:discount_ids => []}
    atn_attrs[:discount_ids] << @discount_nonautomatic.to_param
    atn_attrs[:discount_ids] << @discount_nonautomatic2.to_param
    atn_attrs[:discount_ids] << @discount_automatic.to_param

    # the checkbox list in the view will throw in some empty strings too,
    # so we will test that, and make sure it does not crash
    atn_attrs[:discount_ids] << ""

    assert_difference('a.discounts.count', +2) do
      put :update, {:page => 'baduk', :id => a.to_param, :attendee => atn_attrs}
    end
  end

  test "non-admin cannot claim automatic discounts" do
    sign_in @user
    a = @user.attendees.sample
    assert_equal 0, a.discounts.count
    atn_attrs = {:discount_ids => []}
    atn_attrs[:discount_ids] << @discount_automatic.to_param
    assert_no_difference('a.discounts.count') do
      put :update, {:page => 'baduk', :id => a.to_param, :attendee => atn_attrs}
    end
  end

  test "non-admin cannot get admin page of edit form" do
    sign_in @user
    get :edit, {:page => 'admin', :id => @user.attendees.sample.to_param}
    assert_response 403
  end

end
