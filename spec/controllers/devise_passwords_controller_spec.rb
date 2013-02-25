require 'spec_helper'

describe Devise::PasswordsController do
  render_views

  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe '#create' do
    it "user can create reset password token" do
      u = create :user
      post :create, :user => {:email => u.email, :year => u.year}, :year => u.year
      response.should redirect_to new_user_session_path
    end

    it "reset password token is created for the correct user" do

      # Create two users with the same email address, but different years.
      user2011 = create :user, :email => "jared@jaredbeck.com", :year => 2011
      user2012 = create :user, :email => "jared@jaredbeck.com", :year => 2012

      # Create a reset password token
      post :create, :user => {:email => user2012.email, :year => 2012}, :year => 2012

      # We expect the delivered email to include an anchor with the correct
      # year in the path in the href.  For example:
      # <a href="http://www.gocongress.org/2012/users/password/edit ...
      body = HTML::Document.new(ActionMailer::Base.deliveries.last.body.to_s).root
      assert_select body, 'a[href*=2012]'
      assert_select body, "a[href*=#{user2012.reset_password_token}]"
    end
  end

  describe '#new' do
    it "pw reset form has both year and email" do
      u = create :user
      get :new, :year => u.year
      response.should be_success
      assert_select "input[name*=email]"
      assert_select "input[name*=year][value=#{u.year}]"
    end
  end
end
