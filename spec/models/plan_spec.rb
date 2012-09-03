require "spec_helper"

describe Plan do
  it_behaves_like "a yearly model"

  it "has a valid factory" do
    FactoryGirl.build(:plan).should be_valid
  end

  context "when two attendees have selected it" do
    let(:plan) { FactoryGirl.create :plan }
    before do
      plan.stub attendees: ["alice", "bob"]
    end

    describe "#valid?" do
      it "returns false when inventory is less than attendee count" do
        plan.inventory = 1
        plan.valid?.should be_false
      end

      it "returns true when inventory is equal to attendee count" do
        plan.inventory = 2
        plan.valid?.should be_true
      end

      it "returns true when inventory exceeds attendee count" do
        plan.inventory = 3
        plan.valid?.should be_true
      end
    end
  end
end
