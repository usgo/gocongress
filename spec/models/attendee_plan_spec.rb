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
  end
end
