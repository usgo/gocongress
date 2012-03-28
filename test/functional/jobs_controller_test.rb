require 'test_helper'

class JobsControllerTest < ActionController::TestCase
  setup do
    @job = FactoryGirl.create(:job)
    @user = FactoryGirl.create(:user)
    @admin_user = FactoryGirl.create(:admin)
  end

  test "visitor can get index" do
    get :index, :year => Time.now.year
    assert_response :success
    assert_not_nil assigns(:jobs)
  end

  test "admin can get new" do
    sign_in(@admin_user)
    get :new, :year => Time.now.year
    assert_response :success
  end
  
  test "user cannot get new" do
    sign_in(@user)
    get :new, :year => Time.now.year
    assert_response 403
  end

  test "admin can create job" do
    sign_in(@admin_user)
    assert_difference('Job.count') do
      post :create, :year => Time.now.year, :job => @job.attributes
    end
    assert_redirected_to jobs_path
  end

  test "visitor can show job" do
    get :show, :year => Time.now.year, :id => @job.to_param
    assert_response :success
  end

  test "admin can get edit" do
    sign_in(@admin_user)
    get :edit, :year => Time.now.year, :id => @job.to_param
    assert_response :success
  end
  
  test "user cannot get edit" do
    sign_in(@user)
    get :edit, :year => Time.now.year, :id => @job.to_param
    assert_response 403
  end

  test "admin can update job" do
    sign_in(@admin_user)
    put :update, :year => Time.now.year, :id => @job.to_param, :job => @job.attributes
    assert_redirected_to jobs_path
  end

  test "admin can destroy job" do
    sign_in(@admin_user)
    assert_difference('Job.count', -1) do
      delete :destroy, :year => Time.now.year, :id => @job.to_param
    end
    assert_redirected_to jobs_path
  end
  
  test "user cannot destroy job" do
    sign_in @user
    assert_no_difference 'Job.count' do
      delete :destroy, :year => Time.now.year, :id => @job.id
    end
    assert_response 403
  end

end
