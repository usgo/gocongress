require "rails_helper"

RSpec.describe Registration do
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
        expect(r.submit(ActionController::Parameters.new(params))).to eq(false)
        expect(r.errors.keys).to include(:liability_release)
        expect(attendee.understand_minor).to eq(false)
      end

      it "does not add disabled activity, and returns an error" do
        r = Registration.new user, attendee
        params = {activity_ids: [dsbl_act.id]}
        expect {
          expect(r.submit(ActionController::Parameters.new(params))).to be_falsey
        }.to_not change { AttendeeActivity.count }
      end

      it "does not remove disabled activity, and returns an error" do
        attendee.activities << dsbl_act
        r = Registration.new user, attendee
        expect {
          expect(r.submit(ActionController::Parameters.new({}))).to be_falsey
        }.to_not change { AttendeeActivity.count }
      end

      it "selects shirt style" do
        s = create :shirt
        r = Registration.new user, attendee
        params = {registration: {shirt_id: s.id}}
        expect(r.submit(ActionController::Parameters.new(params))).to eq(true)
        expect(attendee.shirt_id).to eq(s.id)
      end

      context 'when plan selection would exceed inventory' do
        let(:attendee) { build :attendee }
        let(:msg) { 'You requested 1, but there are only 0 available.' }

        it 'adds an error to the attendee, and returns false' do
          p = create :plan, inventory: 1
          create :attendee_plan, plan: p, quantity: 1 # now, ivty is 0
          r = Registration.new user, attendee
          params = {plans: {p.id.to_s => {'qty' => 1}}}
          expect(r.submit(ActionController::Parameters.new(params))).to eq(false)
          expect(r.errors.full_messages.join(', ')).to include(msg)
        end
      end

      context "when there is a mandatory category" do
        let!(:cat) { create :plan_category, :mandatory => true }
        let(:msg) { "Please select at least one plan in #{cat.name}" }

        it 'returns an error if no plan is selected' do
          r = Registration.new user, attendee
          expect(r.submit(ActionController::Parameters.new({}))).to eq(false)
          expect(r.errors.full_messages).to include(msg)
        end

        it 'returns an error if only selection has qty of zero' do
          plan = create :plan, :plan_category => cat
          r = Registration.new user, attendee
          params = {plans: {plan.id.to_s => {"qty" => 0}}}
          expect(r.submit(ActionController::Parameters.new(params))).to eq(false)
          expect(r.errors.full_messages).to include(msg)
        end
      end

      context "when there is a single plan category" do
        let(:category) { create :plan_category, :single => true }
        let(:message) { "Please select exactly one plan in #{category.name}." }

        it "returns an error if selected plan count is greater than 1" do
          p1 = create :plan, plan_category: category
          p2 = create :plan, plan_category: category
          r = Registration.new user, attendee
          params = {plans: {p1.id.to_s => {"qty" => 1}, p2.id.to_s => {"qty" => 1}}}
          expect(r.submit(ActionController::Parameters.new(params))).to eq(false)
          expect(r.errors.full_messages).to include(message)
        end
      end
    end

    context "as an admin" do
      it "adds disabled activities, and returns no errors" do
        act = create(:activity, disabled: true)
        r = Registration.new admin, attendee
        expect {
          expect(r.submit(ActionController::Parameters.new(activity_ids: [act.id]))).to be_truthy
        }.to change { AttendeeActivity.count }.by(+1)
      end

      it "removes disabled activities, and returns no errors" do
        attendee.activities << dsbl_act
        r = Registration.new admin, attendee
        expect {
          expect(r.submit(ActionController::Parameters.new({}))).to be_truthy
        }.to change { AttendeeActivity.count }.by(-1)
      end

      context "disabled plans" do
        it "adds disabled plan" do
          r = Registration.new admin, attendee
          params = {plans: {dsbl_plan.id.to_s => {"qty" => 1}}}
          expect(r.submit(ActionController::Parameters.new(params))).to eq(true)
          expect(attendee.reload.plans).to include dsbl_plan
        end

        it "removes disabled plan" do
          attendee.plans << dsbl_plan
          r = Registration.new admin, attendee
          expect(r.submit(ActionController::Parameters.new(plans: {}))).to eq(true)
          expect(attendee.reload.plans).not_to include dsbl_plan
        end
      end
    end
  end
end
