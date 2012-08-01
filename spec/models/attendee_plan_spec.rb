require "spec_helper"

describe AttendeePlan do
  describe "#valid?" do

    it "requires attendee" do
      ap = FactoryGirl.build :attendee_plan, :attendee => nil
      ap.should_not be_valid
      ap.errors.should include :attendee
    end

    it "has minimum quantity of one" do
      ap = FactoryGirl.build :attendee_plan, :quantity => 0
      ap.should_not be_valid
      ap.errors.should include :quantity
      ap.quantity = -1
      ap.should_not be_valid
      ap.quantity = 1
      ap.should be_valid
    end

    it "is invalid when quantity exceeds plan max_quantity" do
      a = FactoryGirl.create :attendee
      p = FactoryGirl.create :plan, :max_quantity => 1
      ap = AttendeePlan.new :plan_id => p.id, :quantity => p.max_quantity + 1, :attendee_id => a.id
      ap.should_not be_valid
    end
  end
end
