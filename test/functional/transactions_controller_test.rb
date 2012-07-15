require 'test_helper'

class TransactionsControllerTest < ActionController::TestCase
  setup do
    @staff = FactoryGirl.create :staff
    @user = FactoryGirl.create :user
    FactoryGirl.create :primary_attendee, user: @user
    @admin = FactoryGirl.create :admin
    FactoryGirl.create :primary_attendee, user: @admin
    @transaction = FactoryGirl.create :tr_sale, updated_by_user: @admin
    @year = Time.now.year
  end

  test "admin can create transaction" do
    sign_in @admin

    # Build (do not save) a transaction with no user.  The user will
    # be specified via user_email.  This is a new required param,
    # since I added the autocomplete.
    t = FactoryGirl.build :tr_sale, {:user => nil}
    assert_difference("Transaction.where(:year => #{@year}).count", +1) do
      post :create, :transaction => t.attributes, :user_email => @user.email, :year => @year
    end
    assert_redirected_to transaction_path(assigns(:transaction))
  end

  test "admin can update transaction" do
    sign_in @admin
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

private

  def put_to_update(delta_amount, expected_diff)
    amount_before = Transaction.find(@transaction.id).amount
    trn_atr_hash = @transaction.attributes.merge( 'amount' => @transaction.amount + delta_amount )
    put :update,
      :id => @transaction.id,
      :user_email => @transaction.user.email,
      :year => @year,
      :transaction => trn_atr_hash
    amount_after = Transaction.find(@transaction.id).amount
    actual_diff = amount_after - amount_before
    assert (actual_diff - expected_diff).abs < 0.0001, "unexpected change in amount"
  end

end
