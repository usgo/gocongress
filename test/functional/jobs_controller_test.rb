require 'test_helper'

class JobsControllerTest < ActionController::TestCase
  setup do
    @job = jobs(:one)
    @user = Factory.create(:user)
    @admin_user = Factory.create(:admin_user)
  end

  test "visitor should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:jobs)
  end

  test "admin should get new" do
    sign_in(@admin_user)
    get :new
    assert_response :success
  end
  
  test "user should not get new" do
    sign_in(@user)
    get :new
    assert_response 403
  end

  test "admin should create job" do
    sign_in(@admin_user)
    assert_difference('Job.count') do
      post :create, :job => @job.attributes
    end

    assert_redirected_to job_path(assigns(:job))
  end

  test "visitor can show job" do
    get :show, :id => @job.to_param
    assert_response :success
  end

  test "admin should get edit" do
    sign_in(@admin_user)
    get :edit, :id => @job.to_param
    assert_response :success
  end
  
  test "user should not get edit" do
    sign_in(@user)
    get :edit, :id => @job.to_param
    assert_response 403
  end

  test "admin should update job" do
    sign_in(@admin_user)
    put :update, :id => @job.to_param, :job => @job.attributes
    assert_redirected_to job_path(assigns(:job))
  end

  test "admin can destroy job" do
    sign_in(@admin_user)
    assert_difference('Job.count', -1) do
      delete :destroy, :id => @job.to_param
    end

    assert_redirected_to jobs_path
  end
end
