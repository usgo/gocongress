require "spec_helper"

describe Purchasable do
  let(:plan) { Factory.build :plan }

  describe "#contact_msg_instead_of_price?" do
    it "returns true if needs_staff_approval?" do
      plan.stub(:needs_staff_approval?) { true }
      plan.contact_msg_instead_of_price?.should be_true
    end
  end

  describe "#price_for_display" do
    it "obeys contact_msg_instead_of_price?" do
      plan.stub(:contact_msg_instead_of_price?) { true }
      plan.price_for_display.should == "Contact the Registrar"
    end
  end
end
