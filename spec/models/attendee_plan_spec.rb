require "spec_helper"

describe AttendeePlan do
  it_behaves_like "a yearly model"

  describe '#to_plan_selection' do
    let(:dates) { (5..7).map { |d| Date.new(2013, 8, d) } }

    it 'includes dates' do
      ap = create :attendee_plan
      dates.each { |d| ap.dates.create!(_date: d) }
      ps = ap.to_plan_selection
      ps.dates.should =~ dates
    end
  end

  describe "#valid?" do

    it "requires attendee" do
      ap = build :attendee_plan, :attendee => nil
      ap.should_not be_valid
      ap.errors.should include :attendee
    end

    it "has minimum quantity of one" do
      ap = build :attendee_plan, :quantity => 0
      ap.should_not be_valid
      ap.errors.should include :quantity
      ap.quantity = -1
      ap.should_not be_valid
      ap.quantity = 1
      ap.should be_valid
    end

    it "is invalid when quantity exceeds plan max_quantity" do
      a = create :attendee
      p = create :plan, :max_quantity => 1
      ap = AttendeePlan.new :plan_id => p.id, :quantity => p.max_quantity + 1, :attendee_id => a.id
      ap.should_not be_valid
    end

    it "quantity cannot exceed available inventory" do
      p = create :plan, inventory: 42, max_quantity: 999
      build(:attendee_plan, plan: p, quantity: 42).should be_valid
      build(:attendee_plan, plan: p, quantity: 43).should_not be_valid
    end

    context 'daily-rate plans' do

      it 'for daily-rate plans it is ok to specify dates' do
        p = create :plan, daily: true
        build_with_dates(p).should be_valid
      end

      it 'for normal plans, without a daily rate, is not ok to specify dates' do
        p = create :plan, daily: false
        build_with_dates(p).should have_error_about :dates
      end

      def build_with_dates plan
        build :attendee_plan, plan: plan, dates: [build(:attendee_plan_date)]
      end
    end

  end
end
