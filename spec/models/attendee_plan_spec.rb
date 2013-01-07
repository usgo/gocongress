require "spec_helper"

describe AttendeePlan do
  it_behaves_like "a yearly model"

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

    context 'when plan has a daily rate' do
      let(:y) { Year.find_by_year(Date.current.year) }
      let(:p) { create :plan, daily_rate: 6000, year: y.year }
      let(:ap) { create :attendee_plan, plan: p }

      it 'is valid when at least one date is selected' do
        ap.dates << AttendeePlanDate.new(_date: Date.current)
        ap.should be_valid
      end

      it 'is invalid if a date is before start of congress' do
        pending
        ap.dates << AttendeePlanDate.new(_date: y.start_date - 1.day)
        ap.should_not be_valid
      end

      it 'is invalid if a date is after end of congress'
    end

    context 'when plan does not have a daily rate' do
      it 'is invalid to specify days'
    end
  end
end
