require "spec_helper"

# This spec describes a module included by Plan and Activity, so
# it should probably be rewritten as shared examples
describe Purchasable do
  subject { create :plan }

  describe "#contact_msg_instead_of_price?" do
    it "returns true if needs_staff_approval?" do
      subject.stub(:needs_staff_approval?) { true }
      subject.contact_msg_instead_of_price?.should be_true
    end
  end

  describe "#price_for_display" do
    it "obeys contact_msg_instead_of_price?" do
      subject.stub(:contact_msg_instead_of_price?) { true }
      subject.price_for_display.should == "Contact the Registrar"
    end

    it "obeys price_varies?" do
      subject.stub(:price_varies?) { true }
      subject.price_for_display.should == "Varies"
    end
  end

  describe '#valid?' do
    describe 'price' do
      def err_msg_keys price
        p = Plan.new
        p.price = price
        p.valid?
        p.errors.messages.keys
      end

      it 'complains when the price is a decimal' do
        err_msg_keys(4.2).should include(:price)
      end

      it 'does not complain when the price is an integer' do
        err_msg_keys(42).should_not include(:price)
      end

      it 'complains when the price is negative' do
        err_msg_keys(-42).should include(:price)
      end
    end
  end

  context "when at least one attendee has selected it" do
    before do
      subject.attendees << create(:attendee)
    end

    describe "#destroy" do
      it "raises an error" do
        expect { subject.destroy }.to \
          raise_error(ActiveRecord::DeleteRestrictionError)
      end
    end

    describe "#valid?" do
      it "returns false if the price is changed" do
        subject.price += 50
        subject.valid?.should be_false
      end

      it "returns true if zero attributes have changed" do
        subject.valid?.should be_true
      end
    end
  end

end
