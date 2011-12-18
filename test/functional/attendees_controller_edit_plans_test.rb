require 'test_helper'

class AttendeesControllerEditPlansTest < ActionController::TestCase
  setup do
    @controller = AttendeesController.new
    @plan_category = Factory :plan_category
    @plan = Factory :plan, plan_category_id: @plan_category.id
    @user = Factory :user
    @year = Time.now.year
  end

  test "user can get edit_plans form" do
    sign_in @user
    get :edit_plans, :id => @user.attendees.sample.id, :plan_category_id => @plan_category.id, :year => @year
    assert_response :success
  end
  
  test "visitor cannot get edit_plans form" do
    get :edit_plans, :id => @user.attendees.sample.id, :plan_category_id => @plan_category.id, :year => @year
    assert_response :forbidden
  end

end
