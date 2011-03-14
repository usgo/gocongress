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

  test "neither visitor nor non-admin can create transaction" do
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

  test "admin can update transaction" do
    sign_in @admin_user
    delta_amount = (rand() * 100).round(2)
    put_to_update(delta_amount, delta_amount)
    assert_redirected_to transaction_path(assigns(:transaction))
  end

  test "neither visitor nor non-admin can update transaction" do
    put_to_update(rand(100), 0)
    assert_response 403
    sign_in @user
    put_to_update(rand(100), 0)
    assert_response 403
  end

  def put_to_update(delta_amount, expected_difference)
    trn_atr_hash = @transaction.attributes.merge( 'amount' => @transaction.amount + delta_amount )
    assert_difference('Transaction.find(@transaction.to_param).amount', expected_difference) do
      put :update, :id => @transaction.to_param, :transaction => trn_atr_hash
    end
  end

  test "admin can destroy transaction" do
    sign_in @admin_user
    assert_difference('Transaction.count', -1) do
      delete :destroy, :id => @transaction.id
    end
    assert_redirected_to transactions_path
  end

  test "neither visitor nor non-admin can destroy transaction" do
    delete_transaction_should_be_denied
    sign_in @user
    delete_transaction_should_be_denied
  end

  def delete_transaction_should_be_denied
    assert_no_difference('Transaction.count') do
      delete :destroy, :id => @transaction.id
    end
    assert_response 403
  end

end
