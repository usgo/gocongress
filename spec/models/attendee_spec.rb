require "spec_helper"

describe Attendee do
  context "when first created" do
    describe "#has_plans?" do
      it "does not have plans" do
        subject.has_plans?.should == false
      end
    end
  end
end
