require 'test_helper'

class TransactionsControllerTest < ActionController::TestCase
  setup do
    @user = Factory.create :user
    @staff = Factory.create :staff
    @admin_user = Factory.create :admin_user
    @transaction = Factory.create :tr_sale
    @year = Time.now.year
  end

  test "admin can index transactions" do
    sign_in @admin_user
    get :index, :year => @year
    assert_response :success
  end

  test "admin user can get edit form" do
    sign_in @admin_user
    get :edit, :id => @transaction.to_param, :year => @year
    assert_response :success
  end

  test "admin can create valid transaction" do
    sign_in @admin_user

    # build a valid transaction, but do not save it
    t = Factory.build :tr_sale
    assert_equal true, t.valid?

    # post to create
    # note that we also need to pass user_email.
    # this is a new required param, since I added the autocomplete
    assert_difference('Transaction.count', +1) do
      post :create, :transaction => t.attributes, :user_email => t.user.email, :year => @year
    end
    assert_redirected_to transaction_path(assigns(:transaction))
  end

  test "staff can index transactions" do
    sign_in @staff
    get :index, :year => @year
    assert_response :success
  end

  test "guest and user and staff cannot create transaction" do
    post_to_create_should_be_denied
    sign_in @user
    post_to_create_should_be_denied
    sign_in @staff
    post_to_create_should_be_denied
  end

  test "admin can update transaction" do
    sign_in @admin_user
    delta_amount = (rand() * 100).round(2)
    put_to_update(delta_amount, delta_amount)
    assert_redirected_to transaction_path(assigns(:transaction))
  end

  test "guest and user and staff cannot update transaction" do
    put_to_update(rand(100), 0)
    assert_response 403
    sign_in @user
    put_to_update(rand(100), 0)
    assert_response 403
    sign_in @staff
    put_to_update(rand(100), 0)
    assert_response 403
  end

  test "admin can destroy transaction" do
    sign_in @admin_user
    assert_difference('Transaction.count', -1) do
      delete :destroy, :id => @transaction.id, :year => @year
    end
    assert_redirected_to transactions_path
  end

  test "guest and user and staff cannot destroy transaction" do
    delete_transaction_should_be_denied
    sign_in @user
    delete_transaction_should_be_denied
    sign_in @staff
    delete_transaction_should_be_denied
  end

private

  def post_to_create_should_be_denied
    assert_no_difference('Transaction.count') do
      post :create, :transaction => @transaction.attributes, :year => @year
    end
    assert_response 403
  end

  def put_to_update(delta_amount, expected_diff)
    amount_before = Transaction.find(@transaction.id).amount
    trn_atr_hash = @transaction.attributes.merge( 'amount' => @transaction.amount + delta_amount )
    put :update, :id => @transaction.id, :transaction => trn_atr_hash, :year => @year
    amount_after = Transaction.find(@transaction.id).amount
    actual_diff = amount_after - amount_before
    assert (actual_diff - expected_diff).abs < 0.0001, "unexpected change in amount"
  end

  def delete_transaction_should_be_denied
    assert_no_difference('Transaction.count') do
      delete :destroy, :id => @transaction.id, :year => @year
    end
    assert_response 403
  end

end
