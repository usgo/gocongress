require 'test_helper'

class TransactionsControllerTest < ActionController::TestCase
  setup do
    @admin_user = Factory.create(:admin_user)
    @transaction = Factory.create(:transaction)
  end

  test "admin user can get edit form" do
    sign_in @admin_user
    get :edit, :id => @transaction.to_param
    assert_response :success
  end
end
