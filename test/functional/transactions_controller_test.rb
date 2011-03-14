require 'test_helper'

class TransactionsControllerTest < ActionController::TestCase
  setup do
    @user = Factory.create :user
    @admin_user = Factory.create :admin_user
    @transaction = Factory.create :transaction
  end

  test "admin user can get edit form" do
    sign_in @admin_user
    get :edit, :id => @transaction.to_param
    assert_response :success
  end

  test "admin can create valid transaction" do
    sign_in @admin_user

    # build a valid transaction, but do not save it
    @new_transaction = Factory.build :transaction
    assert_equal true, @new_transaction.valid?

    # post to create
    assert_difference('Transaction.count', +1) do
      post :create, :transaction => @new_transaction.attributes
    end
    assert_redirected_to transaction_path(assigns(:transaction))
  end

  test "neither visitor nor non-admin user can create transaction" do
    post_to_create_should_be_denied
    sign_in @user
    post_to_create_should_be_denied
  end

  def post_to_create_should_be_denied
    assert_no_difference('Transaction.count') do
      post :create, :transaction => @transaction.attributes
    end
    assert_response 403
  end
  
end
