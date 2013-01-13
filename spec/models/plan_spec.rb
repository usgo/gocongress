require "spec_helper"

describe Plan do
  it_behaves_like "a yearly model"

  it "has valid factories" do
    build(:plan).should be_valid
    build(:plan_which_needs_staff_approval).should be_valid
  end

  describe '#valid?' do
    it 'requires a nonzero inventory' do
      build(:plan, inventory: 0).should_not be_valid
    end

    it 'requires a positive max qty' do
      build(:plan, :max_quantity => 2).should be_valid
      build(:plan, :max_quantity => 1).should be_valid
      build(:plan, :max_quantity => 0).should have_error_about :max_quantity
      build(:plan, :max_quantity => -1).should have_error_about :max_quantity
    end

    it 'cannot both be daily and need staff approval' do
      build(:plan_which_needs_staff_approval, daily: true).should \
        have_error_about :daily
    end

    it 'cannot both be daily and have a max qty other than one' do
      build(:plan, daily: true, max_quantity: 2).should \
        have_error_about :max_quantity
    end
  end

  describe '#inventory_consumed' do
    it 'is zero for a new plan' do
      Plan.new.inventory_consumed.should == 0
    end

    it 'returns the quantity of associated attendee_plan records' do
      p = create :plan, max_quantity: 3
      a = create :attendee
      create :attendee_plan, attendee: a, plan: p, quantity: 3, year: p.year
      p.inventory_consumed.should == 3
    end
  end

  context "when two attendees have selected it" do
    let(:plan) { create :plan }
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
