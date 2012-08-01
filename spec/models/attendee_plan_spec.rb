require "spec_helper"

describe AttendeePlan do
  describe "#valid?" do


    it "is invalid when quantity exceeds plan max_quantity" do
      a = FactoryGirl.create :attendee
      p = FactoryGirl.create :plan, :max_quantity => 1
      ap = AttendeePlan.new :plan_id => p.id, :quantity => p.max_quantity + 1, :attendee_id => a.id
      ap.should_not be_valid
    end
  end
end
