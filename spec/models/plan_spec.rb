require "rails_helper"

RSpec.describe Plan, :type => :model do
  it_behaves_like "a yearly model"

  let(:cat) { create :plan_category }

  it "has valid factories" do
    expect(build(:plan, :plan_category => cat)).to be_valid
    expect(build(:plan_which_needs_staff_approval, :plan_category => cat)).to be_valid
  end

  describe '#valid?' do
    it 'requires a nonzero inventory' do
      expect(build(:plan, :plan_category => cat, inventory: 0)).not_to be_valid
    end

    it 'requires a positive max qty' do
      expect(build(:plan, :plan_category => cat, :max_quantity => 2)).to be_valid
      expect(build(:plan, :plan_category => cat, :max_quantity => 1)).to be_valid
      expect(build(:plan, :plan_category => cat, :max_quantity => 0)).to have_error_about :max_quantity
      expect(build(:plan, :plan_category => cat, :max_quantity => -1)).to have_error_about :max_quantity
    end

    it 'cannot both be daily and need staff approval' do
      expect(build(:plan_which_needs_staff_approval, :plan_category => cat, daily: true)).to \
        have_error_about :daily
    end

    it 'cannot both be daily and have a max qty other than one' do
      expect(build(:plan, :plan_category => cat, daily: true, max_quantity: 2)).to \
        have_error_about :max_quantity
    end
  end

  describe '#inventory_consumed' do
    it 'is zero for a new plan' do
      expect(Plan.new.inventory_consumed).to eq(0)
    end

    it 'returns qty of plans selections, excluding an attendee, if specified' do
      p = create :plan, max_quantity: 3
      a = create :attendee
      a2 = create :attendee
      create :attendee_plan, attendee: a, plan: p, quantity: 3, year: p.year
      create :attendee_plan, attendee: a2, plan: p, quantity: 2, year: p.year
      expect(p.inventory_consumed).to eq(5)
      expect(p.inventory_consumed(a)).to eq(2)
      expect(p.inventory_consumed(a2)).to eq(3)
    end
  end

  context "when two attendees have selected it" do
    let(:plan) { create :plan }
    let(:a1) { create :attendee }
    let(:a2) { create :attendee }
    let(:a3) { create :attendee, cancelled: true }
    let!(:ap1) { create :attendee_plan, attendee: a1, plan: plan }
    let!(:ap2) { create :attendee_plan, attendee: a2, plan: plan }
    let!(:ap3) { create :attendee_plan, attendee: a3, plan: plan }

    describe "#valid?" do
      it "returns false when inventory is less than attendee count" do
        plan.inventory = 1
        expect(plan.valid?).to be_falsey
      end

      it "returns true when inventory is equal to attendee count" do
        plan.inventory = 2
        expect(plan.valid?).to be_truthy
      end

      it "returns true when inventory exceeds attendee count" do
        plan.inventory = 3
        expect(plan.valid?).to be_truthy
      end
    end
  end
end
