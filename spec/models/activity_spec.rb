require "spec_helper"

describe Activity do
  it_behaves_like "a yearly model"

  it "has a valid factory" do
    build(:activity).should be_valid
  end

  context "when initialized" do
    subject { Activity.new }
    it "is enabled" do
      should_not be_disabled
    end
  end
end
