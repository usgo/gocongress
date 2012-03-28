require 'test_helper'

class PlanCategoriesControllerTest < ActionController::TestCase
  setup do
    @pc = FactoryGirl.create(:plan_category)
    @user = FactoryGirl.create(:user)
    @admin = FactoryGirl.create(:admin)
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

  test "admin can show" do
    sign_in @admin
    get :show, id: @pc.id, year: @year
    assert_response :success
    assert_not_nil assigns(:plan_category)
  end

  test "admin can get index" do
    sign_in @admin
    get :index, :year => @year
    assert_response :success
  end

  test "admin can edit" do
    sign_in @admin
    get :edit, id: @pc.id, year: @year
    assert_response :success
  end

  test "user cannot create" do
    sign_in @user
    post :create, :plan_category => @pc.attributes, :year => @year
    assert_response 403
  end

  test "admin can create" do
    sign_in @admin
    new_category = FactoryGirl.build :plan_category
    assert_difference('PlanCategory.count', +1) do
      post :create, :plan_category => new_category.attributes, :year => @year
    end
    assert_redirected_to plan_category_path(assigns(:plan_category))
  end

  test "user cannot destroy" do
    sign_in @user
    delete :destroy, :id => @pc.id, :year => @year
    assert_response 403
  end

end
