require 'test_helper'

class DevisePasswordsControllerTest < ActionController::TestCase
  setup do
    @controller = Devise::PasswordsController.new
  end

  test "user can create reset password token" do
    u = Factory :user
    post :create, :user => {:email => u.email, :year => u.year}, :year => u.year
    assert_redirected_to new_user_session_path
  end

  test "pw reset form has both year and email" do
    u = Factory :user
    get :new, :year => u.year
    assert_response :success
    assert_select "input[name*=email]"
    assert_select "input[name*=year]"
  end

  test "reset password token is created for the correct user" do

    # Create two users with the same email address, but different years.
    # Do not deliver the usual "welcome emails" because they would make
    # it difficult for us to use assert_select_email() later in this test.
    ActionMailer::Base.perform_deliveries = false
    user2011 = Factory :user, :email => "jared@jaredbeck.com", :year => 2011
    user2012 = Factory :user, :email => "jared@jaredbeck.com", :year => 2012

    # Turn mail delivery back on and create a reset password token
    ActionMailer::Base.perform_deliveries = true
    post :create, :user => {:email => user2012.email, :year => 2012}, :year => 2012

    # We expect the delivered email to include an anchor with the correct
    # year in the path in the href.  For example:
    # <a href="http://www.gocongress.org/2012/users/password/edit ...
    assert_select_email do
      assert_select 'a[href*=2012]'
      assert_select "a[href*=#{user2012.reset_password_token}]"
    end
  end
end
