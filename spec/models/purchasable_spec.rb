require "rails_helper"

# This spec describes a module included by Plan and Activity, so
# it should probably be rewritten as shared examples
RSpec.describe Purchasable, :type => :model do
  subject { create :plan }

  describe "#contact_msg_instead_of_price?" do
    it "returns true if needs_staff_approval?" do
      allow(subject).to receive(:needs_staff_approval?) { true }
      expect(subject.contact_msg_instead_of_price?).to be_truthy
    end
  end

  describe "#price_for_display" do
    it "obeys contact_msg_instead_of_price?" do
      allow(subject).to receive(:contact_msg_instead_of_price?) { true }
      expect(subject.price_for_display).to eq("Contact the Registrar")
    end

    it "obeys n_a?" do
      allow(subject).to receive(:price) { 0 }
      allow(subject).to receive(:n_a?) { true }
      expect(subject.price_for_display).to eq("N/A")
    end

    it "obeys price_varies?" do
      allow(subject).to receive(:price_varies?) { true }
      expect(subject.price_for_display).to eq("Varies")
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
        expect(err_msg_keys(4.2)).to include(:price)
      end

      it 'does not complain when the price is an integer' do
        expect(err_msg_keys(42)).not_to include(:price)
      end

      it 'complains when the price is negative' do
        expect(err_msg_keys(-42)).to include(:price)
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
        expect(subject.valid?).to be_falsey
      end

      it "returns true if zero attributes have changed" do
        expect(subject.valid?).to be_truthy
      end
    end
  end

end
