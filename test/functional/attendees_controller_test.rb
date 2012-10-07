require 'test_helper'

class AttendeesControllerTest < ActionController::TestCase
  setup do
    @user = FactoryGirl.create :user
    FactoryGirl.create :primary_attendee, user: @user
    @user_two = FactoryGirl.create :user
    FactoryGirl.create :primary_attendee, user: @user_two
    @admin = FactoryGirl.create :admin
    FactoryGirl.create :primary_attendee, user: @admin
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
end
