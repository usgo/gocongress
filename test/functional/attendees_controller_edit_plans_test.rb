require 'test_helper'

class AttendeesControllerEditPlansTest < ActionController::TestCase
  setup do
    @controller = AttendeesController.new
    @admin = FactoryGirl.create :admin
    @plan_category = FactoryGirl.create :plan_category
    @plan = FactoryGirl.create :plan, plan_category_id: @plan_category.id

    pa_user = FactoryGirl.create :attendee, is_primary: true
    @user = pa_user.user

    @year = Time.now.year
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
    submit_plans_form a, {}
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
    a = FactoryGirl.create :attendee
    assert_no_difference('a.plans.count') do
      submit_plans_form a, params_for_plan(1)
    end
    assert_response :forbidden
  end

  private

  def submit_plans_form(attendee, params)
    params.merge!(:id => attendee.id, :year => @year)
    put :update, params
  end

  def params_for_plan qty
    { "plan_#{@plan.id}_qty" => qty }
  end
end
