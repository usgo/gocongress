require 'spec_helper'

describe Registration do
  let(:dsbl_act) { create :activity, disabled: true }
  let(:dsbl_plan) { create :plan, disabled: true }
  let(:admin) { create :admin }
  let(:attendee) { create :attendee }
  let(:user) { attendee.user }

  describe '#submit' do
    context "not an admin" do

      it "requires minors to agree to fill out the liability release" do
        attendee.birth_date = 5.years.ago
        r = Registration.new user, attendee
        params = {registration: {understand_minor: false}}
        expect(r.submit(params)).to eq(false)
        expect(r.errors.keys).to include(:liability_release)
      end

      it "does not add disabled activity, and returns an error" do
        r = Registration.new user, attendee
        params = {activity_ids: [dsbl_act.id]}
        expect { r.submit(params).should be_false
          }.to_not change { AttendeeActivity.count }
      end

      it "does not remove disabled activity, and returns an error" do
        attendee.activities << dsbl_act
        r = Registration.new user, attendee
        expect { r.submit({}).should be_false
          }.to_not change { AttendeeActivity.count }
      end

      context "when there is a mandatory category" do
        let!(:cat) { create :plan_category, :mandatory => true }
        let(:msg) { "Please select at least one plan in #{cat.name}" }

        it 'returns an error if no plan is selected' do
          r = Registration.new user, attendee
          expect(r.submit({})).to eq(false)
          expect(r.errors.full_messages).to include(msg)
        end

        it 'returns an error if only selection has qty of zero' do
          plan = create :plan, :plan_category => cat
          r = Registration.new user, attendee
          params = {plans: {plan.id => {"qty" => 0}}}
          expect(r.submit(params)).to eq(false)
          expect(r.errors.full_messages).to include(msg)
        end
      end
    end

    context "as an admin" do
      it "adds disabled activities, and returns no errors" do
        act = create(:activity, disabled: true)
        r = Registration.new admin, attendee
        expect { r.submit(activity_ids: [act.id]).should be_true
          }.to change { AttendeeActivity.count }.by(+1)
      end

      it "removes disabled activities, and returns no errors" do
        attendee.activities << dsbl_act
        r = Registration.new admin, attendee
        expect { r.submit({}).should be_true
          }.to change { AttendeeActivity.count }.by(-1)
      end

      context "disabled plans" do
        it "adds disabled plan" do
          r = Registration.new admin, attendee
          params = {plans: {dsbl_plan.id.to_s => {"qty" => 1}}}
          expect(r.submit(params)).to eq(true)
          attendee.reload.plans.should include dsbl_plan
        end

        it "removes disabled plan" do
          attendee.plans << dsbl_plan
          r = Registration.new admin, attendee
          expect(r.submit(plans: {})).to eq(true)
          attendee.reload.plans.should_not include dsbl_plan
        end
      end
    end
  end
end
