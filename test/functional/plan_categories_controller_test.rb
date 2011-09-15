require 'test_helper'

class PlanCategoriesControllerTest < ActionController::TestCase
  setup do
    @pc = Factory.create(:plan_category)
    @user = Factory.create(:user)
    @admin = Factory.create(:admin_user)
    @year = Time.now.year
  end

  test "admin can get index" do
    sign_in @admin
    get :index, :year => @year
    assert_response :success
    assert_not_nil assigns(:plan_categories)
  end

  test "user cannot get index" do
    sign_in @user
    get :index, :year => @year
    assert_response 403
  end

  test "user cannot create" do
    sign_in @user
    post :create, :plan_category => @pc.attributes, :year => @year
    assert_response 403
  end
  
  test "admin can create" do
    sign_in @admin
    assert @pc.valid?, "factory is not valid"
    assert_difference('PlanCategory.count', +1) do
      post :create, :plan_category => @pc.attributes, :year => @year
    end
    assert_redirected_to plan_category_path(assigns(:plan_category))
  end

  test "user cannot destroy" do
    sign_in @user
    delete :destroy, :id => @pc.id, :year => @year
    assert_response 403
  end

end
