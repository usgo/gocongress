require 'test_helper'

class PlanCategoriesControllerTest < ActionController::TestCase
  setup do
    @pc = FactoryGirl.create(:plan_category)
    @year = Time.now.year
  end

  test "visitors can get index" do
    get :index, :year => @year
    assert_response :success
    assert_not_nil assigns(:plan_categories)
  end

  test "visitor can show" do
    get :show, id: @pc.id, year: @year
    assert_response :success
    assert_not_nil assigns(:plan_category)
  end
end
