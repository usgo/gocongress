require "spec_helper"

describe Activity do
  it "has a valid factory" do
    FactoryGirl.build(:activity).should be_valid
  end
end
