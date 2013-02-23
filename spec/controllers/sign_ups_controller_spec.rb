require "spec_helper"

describe SignUpsController do
  let(:year) { Time.zone.now.year }

  # Every time you want to unit test a devise controller, you need
  # to tell Devise which mapping to use. http://bit.ly/lhjcUm
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe '#new' do
    it 'should succeed' do
      get :new, :year => year
      assert_response :success
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
        expect { post :create, :user => attrs, :year => year
          }.to change { User.count }.by(+1)
        response.should redirect_to new_attendee_path(year)
      end
    end

    context "given an invalid user" do

      def attempt_to_create_invalid_user
        post :create, {:user => {}, :year => year}
      end

      it "does not create a user" do
        expect { attempt_to_create_invalid_user
          }.to_not change{ User.count }
      end

      it "does not sign in a user" do
        attempt_to_create_invalid_user
        warden.authenticated?(:user).should == false
      end

      it "shows the form again" do
        attempt_to_create_invalid_user
        response.should be_success
        response.should render_template("new")
      end
    end

    it "raises error if role parameter is present" do
      u = accessible_attributes_for(:user).merge(role: 'A')
      expect { post :create, :user => u, :year => u[:year]
        }.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
  end
end
