require "spec_helper"

describe User do

  it "has a valid factory" do
    FactoryGirl.build(:user).should be_valid
  end

  it "is invalid if email is invalid" do
    user = FactoryGirl.build :user, :email => "herpderp"
    user.should_not be_valid
    user.errors.should include(:email)
  end

  it "is invalid if email is not unique" do
    extant = FactoryGirl.create :user, :email => "John@example.com"
    user = FactoryGirl.build :user, {email: extant.email, year: extant.year}
    user.should_not be_valid
    user.errors.should include(:email)
  end
end
