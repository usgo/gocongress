require 'test_helper'

class AttendeesControllerEditPlansTest < ActionController::TestCase
  setup do
    @controller = AttendeesController.new
    @admin = Factory :admin
    @plan_category = Factory :plan_category
    @plan = Factory :all_ages_plan, plan_category_id: @plan_category.id
    @user = Factory :user
    @user_two = Factory :user
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
    assert_equal(0, a.plans.count)
    assert_difference('a.plans.count', +1) do
      submit_plans_form a, params_for_plan(1)
    end
  end

	test "user can clear own attendee plans" do
    sign_in @user
    a = @user.attendees.sample
    a.plans << @plan
    assert_equal(1, a.plans.count)
    submit_plans_form a, {} # submit an empty hash for params[:attendee]
    assert_equal(0, a.plans.count)
	end

  test "user can deselect a plan" do
    sign_in @user
    a = @user.attendees.sample
    a.plans << @plan
    assert_equal(1, a.plans.count)
    submit_plans_form a, params_for_plan(0)
    assert_equal(0, a.plans.count)
  end

	test "user can select a plan for their own attendee" do
    sign_in @user
    a = @user.attendees.sample
    assert_equal(0, a.plans.count)
    assert_difference('a.plans.count', +1) do
      submit_plans_form a, params_for_plan(1)
    end
	end

  test "user cannot select plan for attendee belonging to someone else" do
    sign_in @user
    a = @user_two.attendees.sample
    assert_no_difference('a.plans.count') do
      submit_plans_form a, params_for_plan(1)
    end
    assert_response :forbidden
  end

  test "after events page redirect to plan category in correct year" do
    u = Factory :user, year: 2012
    a = u.attendees.sample
    e = Factory :event
    c1 = Factory :plan_category, {name: "aaaaaa", year: 2011, event: e}
    p1 = Factory :all_ages_plan, plan_category_id: c1.id
    c2 = Factory :plan_category, {name: "bbbbbb", year: 2012, event: e}
    p2 = Factory :all_ages_plan, plan_category_id: c2.id

    sign_in(u)
    put :update, :page => 'events', :id => a.id, :year => 2012, :event_ids => [e.id]
    # assert_response :redirect

    # expect to be redirected to a 2012 plan category
    plan_category_id = @response.location.split('/').last.to_i
    assert_equal 2012, PlanCategory.find(plan_category_id).year
  end

  private

  def visit_edit_plans_form
    get :edit_plans,
      :id => @user.attendees.sample.id,
      :plan_category_id => @plan_category.id,
      :year => @year
  end

  def submit_plans_form(attendee, attendee_params_hash)
    put :update_plans,
      :id => attendee.id,
      :plan_category_id => @plan_category.id,
      :attendee => attendee_params_hash,
      :year => @year
  end

  def params_for_plan(qty)
    { "plan_#{@plan.id}_qty" => qty }
  end
end
