require "spec_helper"

describe User do

  context "when initialized" do
    it "is not yet valid" do
      User.new.should_not be_valid
    end
  end

  describe "#amount_paid" do
    it "equals the total of sales minus the total of refunds" do
      user = FactoryGirl.create :user
      sales = 1.upto(3).map{ FactoryGirl.create :tr_sale, user_id: user.id }
      refunds = 1.upto(3).map{ FactoryGirl.create :tr_refund, user_id: user.id }
      sale_total = sales.map(&:amount).reduce(:+)
      refund_total = refunds.map(&:amount).reduce(:+)
      user.amount_paid.should == sale_total - refund_total
    end
  end

  describe "attendeeless scope" do
    it "returns only users with no attendees" do
      a1 = FactoryGirl.create :attendee
      u1 = a1.user
      u2 = FactoryGirl.create :user
      u2.attendees.should be_empty
      User.attendeeless.should == [u2]
    end
  end

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
