require 'test_helper'

class AttendeesControllerEditPlansTest < ActionController::TestCase
  setup do
    @controller = AttendeesController.new
    @plan_category = Factory :plan_category
    @plan = Factory :all_ages_plan, plan_category_id: @plan_category.id
    @user = Factory :user
    @year = Time.now.year
  end

  test "user can get edit_plans form" do
    sign_in @user
    visit_edit_plans_form
    assert_response :success
  end
  
  test "visitor cannot get edit_plans form" do
    visit_edit_plans_form
    assert_response :forbidden
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

  private

  def visit_edit_plans_form
    get :edit_plans, :id => @user.attendees.sample.id, :plan_category_id => @plan_category.id, :year => @year
  end

end
