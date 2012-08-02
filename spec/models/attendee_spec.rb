require "spec_helper"

describe Attendee do
  context "when first created" do
    describe "#has_plans?" do
      it "does not have plans" do
        subject.has_plans?.should == false
      end
    end
  end

  describe ".with_planlessness" do
    let!(:plan) { FactoryGirl.create :plan }
    let!(:a1) { FactoryGirl.create :attendee }
    let!(:a2) { FactoryGirl.create :attendee }

    before(:each) do
      a2.plans << plan
    end

    it "can return all attendees" do
      Attendee.with_planlessness(:all).should =~ [a1, a2]
    end

    it "can return only attendees with plans" do
      Attendee.with_planlessness(:planful).should =~ [a2]
    end

    it "can return only attendees without plans" do
      Attendee.with_planlessness(:planless).should =~ [a1]
    end
  end

  describe "#invoice_items" do
    let(:a) { FactoryGirl.create :attendee }

    it "does not include plans that need staff approval" do
      p = FactoryGirl.create :plan_which_needs_staff_approval
      expect { a.plans << p }.to_not change{a.invoice_items.count}
    end

    it "includes applicable plans" do
      p = FactoryGirl.create :plan
      expect { a.plans << p }.to change{a.invoice_items.count}.by(1)
    end

    it "includes activities" do
      v = FactoryGirl.create :activity
      expect { a.activities << v }.to change{a.invoice_items.count}.by(1)
    end

  end

  describe "#valid?" do
    let(:plan) { FactoryGirl.create :plan, inventory: 42, max_quantity: 999 }

    it "plan quantity cannot exceed available inventory" do
      a = FactoryGirl.create :attendee
      a.attendee_plans.build plan_id: plan.id, quantity: 43
      a.should_not be_valid
    end

    it "plan quantity can equal available inventory" do
      a = FactoryGirl.create :attendee
      a.attendee_plans.build plan_id: plan.id, quantity: 42
      a.should be_valid
    end

    it "requires minors to provide the name of a guardian" do
      a = FactoryGirl.build :attendee
      a.stub(:minor?) { true }
      a.guardian_full_name = nil
      a.should_not be_valid
      a.errors.keys.should include(:guardian_full_name)
    end

    it "requires a birth date" do
      a = FactoryGirl.build :attendee, {:birth_date => nil}
      a.should_not be_valid
      a.errors.keys.should include(:birth_date)
    end

    it "requires minors to agree to fill out the liability release" do
      a = FactoryGirl.build :attendee
      a[:birth_date] = 5.years.ago
      a[:understand_minor] = false
      a.should_not be_valid
      a.errors.keys.should include(:liability_release)
    end
  end
end
