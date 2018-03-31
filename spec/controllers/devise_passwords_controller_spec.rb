require "rails_helper"

RSpec.describe Devise::PasswordsController, :type => :controller do
  render_views

  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe '#create' do
    it "creates a reset password token" do
      u = create :user
      post :create, params: { user: { email: u.email, year: u.year }, year: u.year }
      expect(response).to redirect_to new_user_session_path
    end

    it "creates a token for the correct user" do

      # Create two users with the same email address, but different years.
      user2011 = create :user, :email => "jared@jaredbeck.com", :year => 2011
      user2012 = create :user, :email => "jared@jaredbeck.com", :year => 2012

      # Create a reset password token
      post :create, params: { user: { email: user2012.email, year: 2012 }, year: 2012 }
      @reset_password_token = user2012.send_reset_password_instructions

      # We expect the delivered email to include an anchor with the correct
      # year in the path in the href.  For example:
      # <a href="http://www.gocongress.org/2012/users/password/edit ...
      body = Nokogiri::HTML.parse(ActionMailer::Base.deliveries.last.body.to_s).root
      assert_select body, 'a[href*=?]', '2012'
      assert_select body, 'a[href*=?]', @reset_password_token
    end
  end

  describe '#new' do
    it "pw reset form has both year and email" do
      u = create :user
      get :new, params: { year: u.year }
      expect(response).to be_success
      assert_select "input[name*=email]"
      assert_select 'input[name*=year][value=?]', u.year.to_s
    end
  end
end
