require "spec_helper"

describe RegistrationsController do

  # Every time you want to unit test a devise controller, you need
  # to tell Devise which mapping to use. http://bit.ly/lhjcUm
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe "#create" do
    context "given an invalid user" do
      let(:user) { FactoryGirl.attributes_for :user }

      # Using before(:each) because any_instance.stub() is not
      # supported in before(:all)
      # https://github.com/rspec/rspec-mocks/issues/60
      before(:each) do
        @user_count_before = User.count
        User.any_instance.stub(:valid?).and_return(false)
        post :create, {:user => user, :year => user[:year]}
      end

      it "does not create a user" do
        User.count.should == @user_count_before
      end

      it "does not sign in a user" do
        warden.authenticated?(:user).should == false
      end
    end
  end
end
