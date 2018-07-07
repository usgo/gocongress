require "rails_helper"

RSpec.describe Attendee, :type => :model do
  it_behaves_like "a yearly model"

  it "has a valid factory" do
    expect(build(:attendee)).to be_valid
  end

  context "after initialize" do
    it 'should have no activities' do
      expect(subject.activities).to be_empty
    end

    describe "#has_plans?" do
      it "does not have plans" do
        expect(subject.has_plans?).to eq(false)
      end
    end
  end

  context 'when built by factory' do
    describe '#invoice_total' do
      it 'should return zero' do
        expect(build(:attendee).invoice_total).to eq(0)
      end
    end
  end

  describe ".with_planlessness" do
    let!(:plan) { create :plan }
    let!(:a1) { create :attendee }
    let!(:a2) { create :attendee }
    let!(:a3) { create :attendee, cancelled: true }
    let!(:a4) { create :attendee, cancelled: true }

    before(:each) do
      a2.plans << plan
      a4.plans << plan
    end

    it "can return active attendees with plans" do
      expect(Attendee.with_planlessness(:planful)).to match_array([a2])
    end

    it "can return cancelled attendees or attendees without plans" do
      expect(Attendee.with_planlessness(:planless)).to match_array([a1, a3, a4])
    end

    it "can return all attendees" do
      expect(Attendee.with_planlessness(:all)).to match_array([a1, a2, a3, a4])
    end
  end

  describe '#destroy' do
    it 'also destroys dependent AttendeePlans' do
      a = create(:attendee)
      a.plans << create(:plan)
      expect { a.destroy }.to change { AttendeePlan.count }.by(-1)
      expect(AttendeePlan.where(:attendee_id => a.id)).to be_empty
    end
  end

  describe '#invoice_items' do
    let(:a) { create :attendee }

    it "does not include plans that need staff approval" do
      p = create :plan_which_needs_staff_approval
      expect { a.plans << p }.to_not change{a.invoice_items.count}
    end

    it "includes applicable plans" do
      p = create :plan
      expect { a.plans << p }.to change{a.invoice_items.count}.by(1)
    end

    it "includes activities" do
      v = create :activity
      expect { a.activities << v }.to change{a.invoice_items.count}.by(1)
    end

    def descriptions_of invoice_items
      invoice_items.map{|i| i.description}
    end
  end

  describe '#populate_atrs_for_new_form' do
    it 'copies email from user' do
      u = create :user
      a = build :attendee, user: u
      a.populate_atrs_for_new_form
      expect(a.email).to eq(u.email)
    end

    it 'copies country and phone from first attendee created' do
      u = create :user
      a1 = create :attendee, user: u, country: 'ZW', phone: '1234567890'
      a2 = build :attendee, user: u, country: 'VI', phone: '7777777777'
      a2.populate_atrs_for_new_form
      expect(a2.phone).to eq(a1.phone)
      expect(a2.country).to eq(a1.country)
    end
  end

  describe "#valid?" do
    let(:plan) { create :plan, inventory: 42, max_quantity: 999 }
    let(:a) { build :attendee }

    it 'Attendee must indicate whether or not they will play in the US Open' do
      a.will_play_in_us_open = nil
      expect(a).to have_error_about(:will_play_in_us_open)
      a.will_play_in_us_open = false
      expect(a).to be_valid
    end

    context 'receive_sms set to true' do

      it 'Attendee required to have a local phone' do
        a.receive_sms = true
        a.local_phone = nil
        expect(a).to have_error_about :local_phone
      end

      it 'Attendee local_phone only contains integers' do
        a.receive_sms = true
        a.local_phone = "1612203r456"
        expect(a).to have_error_about :local_phone
      end

      it 'Attendee local_phone is invalid if missing country code' do
        a.receive_sms = true
        a.local_phone = "6122035220" # no country code
        expect(a).to have_error_about :local_phone
      end

      it 'Attendee local_phone is valid with international country code ' do
        a.receive_sms = true
        a.local_phone = "44-20718-38750" # valid number
        expect(a).to be_valid
      end

      it 'Attendee local_phone is valid with international country code' do
        a.receive_sms = true
        a.local_phone = "+551155256325" # example number from Twilio docs
        expect(a).to be_valid
      end

      it 'Attendee local_phone is valid with international country code' do
        a.receive_sms = true
        a.local_phone = "+16122035280" # example number from Twilio docs
        expect(a).to be_valid
      end

    end

    it 'country must be two capital lettters' do
      expect(a.country).to match(/\A[A-Z]{2}\z/)
      a.country = 'United States'
      expect(a).not_to be_valid
      expect(a.errors.keys).to include(:country)
    end

    it "requires a birth date" do
      a.birth_date = nil
      expect(a).not_to be_valid
      expect(a.errors.keys).to include(:birth_date)
    end

    describe 'minors' do
      it "requires minors to provide the name of a guardian" do
        allow(a).to receive(:minor?) { true }
        a.guardian_full_name = nil
        expect(a).not_to be_valid
        expect(a.errors.keys).to include(:guardian_full_name)
      end
    end
  end
end
