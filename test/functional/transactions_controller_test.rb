require 'test_helper'

class TransactionsControllerTest < ActionController::TestCase
  setup do
    @user = FactoryGirl.create :user
    FactoryGirl.create :primary_attendee, user: @user
    @admin = FactoryGirl.create :admin
    FactoryGirl.create :primary_attendee, user: @admin
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

end
