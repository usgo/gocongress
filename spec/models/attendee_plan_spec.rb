require "rails_helper"

RSpec.describe AttendeePlan, :type => :model do
  it_behaves_like "a yearly model"

  describe '#invoiced_quantity' do
    context 'for daily rate plans' do
      let(:plan) { create :plan, daily: true }
      it 'returns the number of dates' do
        ap = create :attendee_plan, plan: plan, year: 2013
        dates = (5..7).map { |d| Date.new(2013, 8, d) }
        dates.map { |d| ap.dates.create!(_date: d) }
        expect(ap.invoiced_quantity).to eq(dates.length)
      end
    end

    context 'for fixed price plans' do
      it 'returns the persisted quantity' do
        p = create :plan, max_quantity: 5
        ap = create :attendee_plan, plan: p, quantity: 3
        expect(ap.invoiced_quantity).to eq(3)
      end
    end
  end

  describe '#to_plan_selection' do
    let(:dates) { (5..7).map { |d| Date.new(2013, 8, d) } }

    it 'includes dates' do
      p = create :plan
      ap = create :attendee_plan, plan: p
      dates.each { |d| ap.dates.create!(_date: d) }
      ps = ap.to_plan_selection
      expect(ps.dates).to match_array(dates)
    end
  end

  describe "#valid?" do

    it "has minimum quantity of one" do
      ap = build :attendee_plan, :quantity => 0
      expect(ap).not_to be_valid
      expect(ap.errors).to include :quantity
      ap.quantity = -1
      expect(ap).not_to be_valid
      ap.quantity = 1
      expect(ap).to be_valid
    end

    it "is invalid when quantity exceeds plan max_quantity" do
      a = create :attendee
      p = create :plan, :max_quantity => 1
      ap = AttendeePlan.new :plan_id => p.id, :quantity => p.max_quantity + 1, :attendee_id => a.id
      expect(ap).not_to be_valid
    end

    it "quantity cannot exceed available inventory" do
      p = create :plan, inventory: 42, max_quantity: 999
      expect(build(:attendee_plan, plan: p, quantity: 42)).to be_valid
      expect(build(:attendee_plan, plan: p, quantity: 43)).not_to be_valid
    end

    it "is invalid when attendee age is less than minimum age for plan" do
      a = create :minor
      p = create :plan, age_min: 18
      ap = build :attendee_plan, plan: p, attendee_id: a.id
      expect(ap).not_to be_valid
    end

    it "is invalid when attendee age is greater than maximum age for plan" do
      a = create :attendee
      p = create :plan, age_max: 17
      ap = build :attendee_plan, plan: p, attendee_id: a.id
      expect(ap).not_to be_valid
    end

    context 'daily-rate plans' do

      it 'for daily-rate plans it is ok to specify dates' do
        p = create :plan, daily: true
        expect(build_with_dates(p)).to be_valid
      end

      it 'for normal plans, without a daily rate, is not ok to specify dates' do
        p = create :plan, daily: false
        expect(build_with_dates(p)).to have_error_about :dates
      end

      def build_with_dates plan
        build :attendee_plan, plan: plan, dates: [build(:attendee_plan_date)]
      end
    end

  end
end
