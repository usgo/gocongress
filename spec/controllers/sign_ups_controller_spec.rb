require "rails_helper"

RSpec.describe SignUpsController, :type => :controller do
  let(:year) { Time.zone.now.year }
  let(:user_attributes) { { :email => "test@gocongress.org", :password => "password", :password_confirmation => "password" } }
  let(:invalid_user_attributes) { { :email => "", :password => "password", :password_confirmation => "password" } }

  # Every time you want to unit test a devise controller, you need
  # to tell Devise which mapping to use. http://bit.ly/lhjcUm
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe '#new' do
    it 'should succeed' do
      get :new, params: { :year => year }
      if year == 2019
        assert_redirected_to year_path
      else
        assert_response :success
      end
    end
  end

  describe "#create" do
    context "given a valid attributes" do
      let(:attrs) {{
        email: 'example@example.com',
        password: 'asdfasdf',
        password_confirmation: 'asdfasdf',
        year: year }}

      it "succeeds" do
        if year == 2019
          expect {
            post :create, params: { user: attrs, year: year }
          }.to change { User.count }.by(0)
          expect(response).to redirect_to year_path
        else
          expect {
            post :create, params: { user: attrs, year: year }
          }.to change { User.count }.by(+1)
          expect(response).to redirect_to user_path(User.last)
        end
      end
    end

    context "given an invalid user" do

      def attempt_to_create_invalid_user
        post :create, params: { user: invalid_user_attributes, year: year }
      end

      it "does not create a user" do
        expect {
          attempt_to_create_invalid_user
        }.to_not change{ User.count }
      end

      it "does not sign in a user" do
        attempt_to_create_invalid_user
        expect(warden.authenticated?(:user)).to eq(false)
      end

      it "shows the form again" do
        attempt_to_create_invalid_user
        if year == 2019
          expect(response.status).to eq(302)
        else
          expect(response).to be_success
          expect(response).to render_template("new")
        end
      end
    end

    it "raises error if role parameter is present" do
      u = user_attributes.merge(role: 'A')
      if year == 2019
        expect {
          post :create, params: { user: u, year: year }
        }.to change { User.count }.by(0)
      else
        expect {
          post :create, params: { user: u, year: year }
        }.to raise_error(ActionController::UnpermittedParameters)
      end
    end
  end
end
