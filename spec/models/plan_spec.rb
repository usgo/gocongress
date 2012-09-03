require "spec_helper"

describe Plan do
  it_behaves_like "a yearly model"

  context "when it has an inventory of three" do
    subject { FactoryGirl.create :plan, inventory: 3 }

    context "when two attendees have selected it" do
      before do
        1.upto(2) { subject.attendees << FactoryGirl.create(:attendee) }
      end

      describe "#valid?" do
        it "returns false when the inventory is reduced below the attendee count" do
          subject.inventory = 1
          subject.valid?.should be_false
        end

        it "returns true when the inventory is decreased to equal the attendee count" do
          subject.inventory = 2
          subject.valid?.should be_true
        end

        it "returns true when the inventory is increased" do
          subject.inventory = 10
          subject.valid?.should be_true
        end
      end # describe

    end # context
  end # context

end # describe
