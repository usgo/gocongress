require "spec_helper"

describe Attendee do
  it_behaves_like "a yearly model"

  it "has a valid factory" do
    build(:attendee).should be_valid
  end

  context "after initialize" do
    it 'should have no activities' do
      subject.activities.should be_empty
    end

    it 'should have no discounts' do
      subject.discounts.should be_empty
    end

    describe "#has_plans?" do
      it "does not have plans" do
        subject.has_plans?.should == false
      end
    end
  end

  context 'when built by factory' do
    describe '#invoice_total' do
      it 'should return zero' do
        build(:attendee).invoice_total.should == 0
      end
    end
  end

  describe ".with_planlessness" do
    let!(:plan) { create :plan }
    let!(:a1) { create :attendee }
    let!(:a2) { create :attendee }

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
    let(:a) { create :attendee }

    it "does not include plans that need staff approval" do
      p = create :plan_which_needs_staff_approval
      expect { a.plans << p }.to_not change{a.invoice_items.count}
    end

    it "includes applicable plans" do
      p = create :plan
      expect { a.plans << p }.to change{a.invoice_items.count}.by(1)
    end

    it "includes activities" do
      v = create :activity
      expect { a.activities << v }.to change{a.invoice_items.count}.by(1)
    end

    it "only includes discounts from the attendee's year" do
      dc_2011 = create :discount_for_child, :year => 2011
      dc_now = create :discount_for_child
      a = create :child
      item_descriptions = a.invoice_items.map{|i| i.description}
      item_descriptions.should include(dc_now.get_invoice_item_name)
      item_descriptions.should_not include(dc_2011.get_invoice_item_name)
    end
  end

  describe '#minor?' do
    context 'The 2012 congress starts on 8/4' do
      it 'John will be 18' do
        john = build(:attendee, birth_date: Date.new(1994, 7, 5), year: 2012)
        john.should_not be_minor
      end

      it 'Jane will be 17' do
        jane = build(:attendee, birth_date: Date.new(1994, 10, 1), year: 2012)
        jane.should be_minor
      end
    end
  end

  describe "#valid?" do
    let(:plan) { create :plan, inventory: 42, max_quantity: 999 }

    it "plan quantity cannot exceed available inventory" do
      a = create :attendee
      a.attendee_plans.build plan_id: plan.id, quantity: 43
      a.should_not be_valid
    end

    it "plan quantity can equal available inventory" do
      a = create :attendee
      a.attendee_plans.build plan_id: plan.id, quantity: 42
      a.should be_valid
    end

    it "requires minors to provide the name of a guardian" do
      a = build :attendee
      a.stub(:minor?) { true }
      a.guardian_full_name = nil
      a.should_not be_valid
      a.errors.keys.should include(:guardian_full_name)
    end

    it "requires a birth date" do
      a = build :attendee, {:birth_date => nil}
      a.should_not be_valid
      a.errors.keys.should include(:birth_date)
    end

    it "requires minors to agree to fill out the liability release" do
      a = build :attendee
      a[:birth_date] = 5.years.ago
      a[:understand_minor] = false
      a.should_not be_valid
      a.errors.keys.should include(:liability_release)
    end
  end
end
