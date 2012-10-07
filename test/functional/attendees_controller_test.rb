require 'test_helper'

class AttendeesControllerTest < ActionController::TestCase
  setup do
    @user = FactoryGirl.create :user
    FactoryGirl.create :primary_attendee, user: @user
    @user_two = FactoryGirl.create :user
    FactoryGirl.create :primary_attendee, user: @user_two
    @admin = FactoryGirl.create :admin
    FactoryGirl.create :primary_attendee, user: @admin
    @discount_automatic = FactoryGirl.create(:automatic_discount)
    @discount_nonautomatic = FactoryGirl.create(:nonautomatic_discount)
    @discount_nonautomatic2 = FactoryGirl.create(:nonautomatic_discount)
    @inv_trn = FactoryGirl.create(:tournament, :openness => 'I')
    @open_trn = FactoryGirl.create(:tournament, :openness => 'O')
    @year = Time.now.year
  end

  test "user cannot edit another user's attendee" do
    sign_in @user
    get :edit, :id => @user_two.attendees.sample.id, :year => @year, :page => :basics
    assert_response 403
  end

  test "user can edit their own attendees" do
    sign_in @user
    get :edit, :id => @user.attendees.sample.id, :year => @year, :page => :basics
    assert_response :success
  end

  test "admin can edit any attendee" do
    sign_in @admin
    get :edit, :id => @user.attendees.sample.id, :year => @year, :page => :basics
    assert_response :success
    get :edit, :id => @user_two.attendees.sample.id, :year => @year, :page => :basics
    assert_response :success
    get :edit, :id => @admin.attendees.sample.id, :year => @year, :page => :basics
    assert_response :success
  end

  test "user cannot update another user's attendee" do
    sign_in @user
    target_attendee = @user_two.attendees.first
    target_attendee.family_name = 'Bumbleplotz'
    put :update,
      :id => target_attendee.id,
      :attendee => target_attendee.attributes,
      :year => @year
    assert_response 403
  end

  test "admin can update attendee of any user" do
    sign_in @admin
    target_attendee = @user.attendees.last
    name_before = target_attendee.family_name
    target_attendee.family_name = 'Bumbleplotz'
    put :update,
      :id => target_attendee.id,
      :attendee => target_attendee.attributes,
      :year => @year
    target_attendee.reload
    assert_not_equal name_before, target_attendee.family_name
  end

  test "user can edit own attendees" do
    sign_in @user
    get :edit, :id => @user.attendees.sample.id, :page => 'basics', :year => @year
    assert_response :success
    assert_template 'edit'
  end

  test "visitor cannot edit attendee" do
    get :edit, :id => @admin.attendees.sample.id, :page => 'basics', :year => @year
    assert_response 403
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
      put :update, :page => 'basics', :id => a.id, :attendee => atn_attrs, :year => @year
    end
  end

  test "non-admin cannot claim automatic discounts" do
    sign_in @user
    a = @user.attendees.sample
    assert_equal 0, a.discounts.count
    atn_attrs = {:discount_ids => []}
    atn_attrs[:discount_ids] << @discount_automatic.id
    assert_no_difference('a.discounts.count') do
      put :update, :page => 'basics', :id => a.id, :attendee => atn_attrs, :year => @year
    end
  end
end
