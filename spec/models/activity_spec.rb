require "spec_helper"

describe Activity do
  it "has a valid factory" do
    FactoryGirl.build(:activity).should be_valid
  end
  context "when initialized" do
    subject { Activity.new }
    it "is enabled" do
      should_not be_disabled
    end
  end
end

