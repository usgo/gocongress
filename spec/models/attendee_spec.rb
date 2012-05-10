require "spec_helper"

describe Attendee do
  context "when first created" do
    describe "#has_plans?" do
      it "does not have plans" do
        subject.has_plans?.should == false
      end
    end
  end

  describe "#valid?" do
    it "requires minors to provide the name of a guardian" do
      a = FactoryGirl.build :attendee
      a.stub(:minor?) { true }
      a.guardian_full_name = nil
      a.should_not be_valid
      a.errors.keys.should include(:guardian_full_name)
    end
  end

  describe "#invoice_items" do
    it "does not include plans that need staff approval" do
      a = FactoryGirl.create :attendee
      p = FactoryGirl.create :plan_which_needs_staff_approval
      expect { a.plans << p }.to_not change{a.invoice_items.count}
    end

    it "includes applicable plans" do
      a = FactoryGirl.create :attendee
      p = FactoryGirl.create :plan
      expect { a.plans << p }.to change{a.invoice_items.count}.by(1)
    end
  end
end
