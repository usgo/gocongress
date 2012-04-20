require "spec_helper"

describe User do
  it "validates email" do
    user = FactoryGirl.build :user, :email => "herpderp"
    user.should_not be_valid
    user.errors.should include(:email)
  end
end
