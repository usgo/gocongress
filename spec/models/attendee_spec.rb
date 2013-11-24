require "spec_helper"

describe Attendee do
  it_behaves_like "a yearly model"

  it "has a valid factory" do
    build(:attendee).should be_valid
  end

  context "after initialize" do
    it 'should have no activities' do
      subject.activities.should be_empty
    end

    describe "#has_plans?" do
      it "does not have plans" do
        subject.has_plans?.should == false
      end
    end
  end

  context 'when built by factory' do
    describe '#invoice_total' do
      it 'should return zero' do
        build(:attendee).invoice_total.should == 0
      end
    end
  end

  describe ".with_planlessness" do
    let!(:plan) { create :plan }
    let!(:a1) { create :attendee }
    let!(:a2) { create :attendee }

    before(:each) do
      a2.plans << plan
    end

    it "can return all attendees" do
      Attendee.with_planlessness(:all).should =~ [a1, a2]
    end

    it "can return only attendees with plans" do
      Attendee.with_planlessness(:planful).should =~ [a2]
    end

    it "can return only attendees without plans" do
      Attendee.with_planlessness(:planless).should =~ [a1]
    end
  end

  describe '#destroy' do
    it 'also destroys dependent AttendeePlans' do
      a = create(:attendee)
      a.plans << create(:plan)
      expect { a.destroy }.to change { AttendeePlan.count }.by(-1)
      AttendeePlan.where(:attendee_id => a.id).should be_empty
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
      a.email.should == u.email
    end

    it 'copies country and phone from first attendee created' do
      u = create :user
      a1 = create :attendee, user: u, country: 'ZW', phone: '1234567890'
      a2 = build :attendee, user: u, country: 'VI', phone: '7777777777'
      a2.populate_atrs_for_new_form
      a2.phone.should == a1.phone
      a2.country.should == a1.country
    end
  end

  describe "#valid?" do
    let(:plan) { create :plan, inventory: 42, max_quantity: 999 }
    let(:a) { build :attendee }

    it 'Attendee must indicate whether or not they will play in the US Open' do
      a.will_play_in_us_open = nil
      a.should have_error_about(:will_play_in_us_open)
      a.will_play_in_us_open = false
      a.should be_valid
    end

    it 'country must be two capital lettters' do
      a.country.should match /\A[A-Z]{2}\z/
      a.country = 'United States'
      a.should_not be_valid
      a.errors.keys.should include(:country)
    end

    it "requires a birth date" do
      a.birth_date = nil
      a.should_not be_valid
      a.errors.keys.should include(:birth_date)
    end

    describe 'minors' do
      it "requires minors to provide the attendee id of a guardian" do
        a.stub(:minor?) { true }
        a.guardian = nil
        a.should_not be_valid
        a.should have_error_about(:guardian)
        a.guardian = create(:attendee)
        a.should_not have_error_about(:guardian)
      end
    end
  end
end
