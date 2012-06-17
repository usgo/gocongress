require "spec_helper"

describe RegistrationsController do

  # Every time you want to unit test a devise controller, you need
  # to tell Devise which mapping to use. http://bit.ly/lhjcUm
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe "#create" do
    context "given an invalid user" do

      def attempt_to_create_invalid_user
        post :create, {:user => {}, :year => Time.now.year}
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

    it "ignores role parameter" do
      u = FactoryGirl.attributes_for(:user, role: 'A') # A for admin
      expect { post :create, :user => u, :year => u[:year]
        }.to change{ User.count }.by(+1)
      response.should be_redirect
      assigns(:user).role.should == 'U'
    end
  end
end
