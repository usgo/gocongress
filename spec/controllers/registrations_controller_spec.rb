require "spec_helper"

describe RegistrationsController do

  # Every time you want to unit test a devise controller, you need
  # to tell Devise which mapping to use. http://bit.ly/lhjcUm
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe "#create" do
    context "given invalid user attributes" do
      let(:user) { FactoryGirl.attributes_for :user, :email => "herpderp" }

      it "does not create or sign in a user" do
        expect {
          post :create, {:user => user, :year => user[:year]}
        }.not_to change{ User.count }
        warden.authenticated?(:user).should == false
      end
    end
  end

end
