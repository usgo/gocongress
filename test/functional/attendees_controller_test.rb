require 'test_helper'

class AttendeesControllerTest < ActionController::TestCase
  setup do
    @attendee = Factory.create(:attendee)
    @user = Factory.create(:user)
    @user_two = Factory.create(:user)
    @admin = Factory.create(:admin)
    @plan = Factory.create(:all_ages_plan)
    @discount_automatic = Factory.create(:automatic_discount)
    @discount_nonautomatic = Factory.create(:nonautomatic_discount)
    @discount_nonautomatic2 = Factory.create(:nonautomatic_discount)
    @inv_trn = Factory.create(:tournament, :openness => 'I')
    @open_trn = Factory.create(:tournament, :openness => 'O')
    @year = Time.now.year
  end

  test "visitor can get index" do
    get :index, :year => @year
    assert_response :success
  end

  test "visitor cannot get new form" do
    get :new, :year => @year
    assert_response 403
  end

  test "visitor cannot create attendee" do
    a = Factory.attributes_for(:attendee)
    assert_no_difference('Attendee.count', 0) do
      post :create, :attendee => a, :year => @year
    end
    assert_response 403
  end

  test "user cannot create attendee under a different user" do
    sign_in @user
    a = Factory.attributes_for(:attendee)
    a['user_id'] = @user_two.id
    assert_no_difference('Attendee.count', 0) do
      post :create, :attendee => a, :year => @year
    end
    assert_response 403
  end

  test "admin can create attendee under a different user" do
    sign_in @admin
    a = Factory.attributes_for(:attendee)
    a['user_id'] = @user.id
    assert_difference('@user.attendees.count', +1) do
      post :create, :attendee => a, :year => @year
    end
  end

  test "user can create attendee under own account" do
    sign_in @user
    a = Factory.attributes_for(:attendee)
    a['user_id'] = @user.id
    assert_difference('Attendee.where(:user_id => @user.id).count', +1) do
      post :create, :attendee => a, :year => @year
    end
  end

  test "non-admin can destroy own non-primary attendee" do
    sign_in @user
    a = Factory(:attendee, :user_id => @user.id)
    @user.save
    assert_equal 1, @user.attendees.where(:is_primary => false).count
    assert_difference('Attendee.count', -1) do
      delete :destroy, :id => a.id, :year => @year
    end
    assert_equal 0, @user.attendees.where(:is_primary => false).count
    assert_redirected_to user_path(@user)
  end

  test "non-admin cannot destroy any primary attendee" do
    sign_in @user
    assert_no_difference('Attendee.count') do
      delete :destroy, :id => @user.primary_attendee.id, :year => @year
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
      delete :destroy, :id => a.id, :year => @year
    end
    assert_response 403
  end

  test "admin can destroy attendee" do
    sign_in @admin
    assert_difference('Attendee.count', -1) do
      delete :destroy, :id => @attendee.id, :year => @year
    end
    assert_redirected_to user_path(@attendee.user)
    assert_equal 'Attendee deleted', flash[:notice]
  end

  test "admin can destroy primary attendee" do
    sign_in @admin
    assert_equal 1, @user.attendees.where(:is_primary => true).count
    assert_difference('Attendee.count', -1) do
      delete :destroy, :id => @user.primary_attendee.id, :year => @year
    end
    assert_redirected_to user_path(@user)
  end

  test "visitor cannot get edit" do
    get :edit, :id => @attendee.id, :year => @year, :page => :basics
    assert_response 403
  end

  test "user cannot edit another user's attendee" do
    sign_in @user
    get :edit, :id => @attendee.id, :year => @year, :page => :basics
    assert_response 403
  end

  test "user can edit their own attendees" do
    sign_in @user
    get :edit, :id => @user.attendees.first.id, :year => @year, :page => :basics
    assert_response :success
  end

  test "admin can edit any attendee" do
    sign_in @admin
    get :edit, :id => @attendee.id, :year => @year, :page => :basics
    assert_response :success
    get :edit, :id => @user.attendees.last.id, :year => @year, :page => :basics
    assert_response :success
    get :edit, :id => @admin.attendees.first.id, :year => @year, :page => :basics
    assert_response :success
  end

  test "user cannot update another user's attendee" do
    sign_in @user
    target_attendee = @user_two.attendees.first
    target_attendee.state = 'NY'
    put :update, :id => target_attendee.id, :attendee => target_attendee.attributes, :year => @year
    assert_response 403
  end

  test "admin can update attendee of any user" do
    sign_in @admin

    target_attendee = @user.attendees.last
    state_before = target_attendee.state
    target_attendee.state = 'MI'
    put :update, :id => target_attendee.id, :attendee => target_attendee.attributes, :year => @year
    
    target_attendee = Attendee.find(target_attendee.id)
    assert_not_equal state_before, target_attendee.state

    assert_redirected_to user_path(@user.id)
    assert_equal 'Attendee updated', flash[:notice]
  end

  %w[basics baduk roomboard].each do |page|
    define_method "test_user_can_get_#{page}" do
      sign_in @user
      get :edit, :id => @user.attendees.sample.id, :page => page, :year => @year
      view_name = @controller.send( :get_view_name_from_page, page )
      assert_response :success
      assert_template view_name
    end

    define_method "test_vistor_can_not_get_#{page}" do
      get :edit, :id => @admin.attendees.sample.id, :page => page, :year => @year
      view_name = @controller.send( :get_view_name_from_page, page )
      assert_response 403
    end
  end

	test "user can select a plan for their own attendee" do
    sign_in @user
    a = @user.attendees.sample
    assert_equal(0, a.plans.count)
    p = Plan.all.sample
    assert_difference('a.plans.count', +1) do
      put :update, :id => a.id, :page => 'roomboard', :attendee => { "plan_#{p.id}_qty" => 1 }, :year => @year
    end
    assert_redirected_to user_path(@user.id)
	end

  test "user cannot select plan for attendee belonging to someone else" do
    sign_in @user
    a = @user_two.attendees.sample
    h = { "plan_#{@plan.id}_qty" => 1 }
    assert_no_difference('a.plans.count') do
      put :update, :id => a.id, :page => 'roomboard', :attendee => h, :year => @year
    end
    assert_response 403
  end

  test "admin can select plan for attendee belonging to someone else" do
    sign_in @admin
    a = @user.attendees.sample
    h = { "plan_#{@plan.id}_qty" => 1 }
    assert_equal(0, a.plans.count)
    assert_difference('a.plans.count', +1) do
      put :update, :id => a.id, :page => 'roomboard', :attendee => h, :year => @year
    end
    assert_redirected_to user_path(@user.id)
  end

	test "user can clear own attendee plans" do
    sign_in @user
    a = @user.attendees.sample
    a.plans << @plan
    assert_equal(1, a.plans.count)
    put :update, :id => a.id, :page => 'roomboard', :attendee => {}, :year => @year
    assert_equal(0, a.plans.count)
    assert_redirected_to user_path(@user.id)
	end

  test "user can deselect a plan" do
    sign_in @user
    a = @user.attendees.sample
    a.plans << @plan
    assert_equal(1, a.plans.count)
    h = { "plan_#{@plan.id}_qty" => 0 }
    put :update, :id => a.id, :page => 'roomboard', :attendee => h, :year => @year
    assert_equal(0, a.plans.count)
    assert_redirected_to user_path(@user.id)
  end

  test "admin can update deposit_received_at" do
    sign_in @admin

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
    put :update, :id => a.id, :attendee => atn_atr_hash, :page => 'admin', :year => @year

    # assert that deposit_received_at has been updated
    a = Attendee.find(a.id)
    assert_equal new_date, a.deposit_received_at

    # PUTing a date with any missing fields should clear the date entirely
    atn_atr_hash = {}
    atn_atr_hash["deposit_received_at(3i)"] = ""
    put :update, :id => a.id, :attendee => atn_atr_hash, :page => 'admin', :year => @year
    a = Attendee.find(a.id)
    assert_equal nil, a.deposit_received_at
  end

  test "non-admin can claim non-automatic discounts" do
    sign_in @user
    a = @user.attendees.sample
    assert_equal 0, a.discounts.count
    atn_attrs = {:discount_ids => []}
    atn_attrs[:discount_ids] << @discount_nonautomatic.id
    atn_attrs[:discount_ids] << @discount_nonautomatic2.id
    atn_attrs[:discount_ids] << @discount_automatic.id

    # the checkbox list in the view will throw in some empty strings too,
    # so we will test that, and make sure it does not crash
    atn_attrs[:discount_ids] << ""

    assert_difference('a.discounts.count', +2) do
      put :update, :page => 'baduk', :id => a.id, :attendee => atn_attrs, :year => @year
    end
  end

  test "non-admin cannot claim automatic discounts" do
    sign_in @user
    a = @user.attendees.sample
    assert_equal 0, a.discounts.count
    atn_attrs = {:discount_ids => []}
    atn_attrs[:discount_ids] << @discount_automatic.id
    assert_no_difference('a.discounts.count') do
      put :update, :page => 'baduk', :id => a.id, :attendee => atn_attrs, :year => @year
    end
  end

  test "non-admin cannot get admin page of edit form" do
    sign_in @user
    get :edit, :page => :admin, :id => @user.attendees.sample.id, :year => @year
    assert_response 403
  end

  test "non-admin cannot update the admin page" do
    sign_in @user
    a = @user.attendees.first
    put :update, :id => a.id, :attendee => a.attributes, :page => 'admin', :year => @year
    assert_response 403
  end

  test "admin can update invitational tournaments" do
    sign_in @admin
    a = @user.attendees.first
    a.tournaments.clear
    assert_equal(0, AttendeeTournament.where('attendee_id = ?', a.id).count)
    atn_attrs = {:tournament_id_list => [@inv_trn.id]}
    assert_difference('AttendeeTournament.count', +1) do
      put :update, :id => a.id, :attendee => atn_attrs, :page => 'admin', :year => @year
    end
    a.tournaments.reload
    assert a.tournaments.first.present?
    assert_equal(@inv_trn.id, a.tournaments.first.id)
    assert_redirected_to user_path(@user)
  end
  
  test "user can sign up for open tournaments" do
    sign_in @user
    a = @user.attendees.first
    a.tournaments.clear
    atn_attrs = {:tournament_id_list => [@open_trn.id]}
    assert_difference('AttendeeTournament.count', +1) do
      put :update, :id => a.id, :attendee => atn_attrs, :page => 'tournaments', :year => @year
    end
    a.tournaments.reload
    assert a.tournaments.first.present?
    assert_equal(@open_trn.id, a.tournaments.first.id)
    assert_redirected_to user_path(@user)
  end

  test "user can add events to own attendee" do
    sign_in @user
    a = @user.attendees.first
    a.events.clear
    e = Factory :event
    e2 = Factory :event
    atn_attrs = {:event_id_list => [e.id, e2.id]}
    assert_difference('a.events.count', +2) do
      put :update, :id => a.id, :attendee => atn_attrs, :page => 'events', :year => @year
    end
    assert_redirected_to user_path(@user)
  end

  test "user cannot add events to attendee belonging to someone else" do
    sign_in @user
    a = @user_two.attendees.first
    a.events.clear
    e = Factory :event
    atn_attrs = {:event_id_list => [e.id]}
    assert_no_difference('AttendeeEvent.count') do
      put :update, :id => a.id, :attendee => atn_attrs, :page => 'events', :year => @year
    end
    assert_response 403
  end

  test "admin can add events to attendee belonging to someone else" do
    sign_in @admin
    a = @user_two.attendees.first
    a.events.clear
    e = Factory :event
    atn_attrs = {:event_id_list => [e.id]}
    assert_difference('a.events.count', +1) do
      put :update, :id => a.id, :attendee => atn_attrs, :page => 'events', :year => @year
    end
    assert_redirected_to user_path(@user_two)
  end

end
