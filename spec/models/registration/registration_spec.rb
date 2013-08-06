require 'spec_helper'

describe Registration::Registration do
  let(:dsbl_act) { create :activity, disabled: true }
  let(:dsbl_plan) { create :plan, disabled: true }

  context "not an admin" do
    let(:admin) { false }

    describe '#save' do
      it "does not add disabled activity, and returns an error" do
        a = build :attendee
        r = Registration::Registration.new a, admin, {}, [], [dsbl_act.id]
        expect { r.save.should_not be_empty
          }.to_not change { AttendeeActivity.count }
      end

      it "does not remove disabled activity, and returns an error" do
        a = create :attendee
        a.activities << dsbl_act
        r = Registration::Registration.new a, admin, {}, [], []
        expect { r.save.should_not be_empty
          }.to_not change { AttendeeActivity.count }
      end
    end

    describe '#register_plans' do
      let(:attendee) { create :attendee }

      it 'returns something enumerable' do
        r = Registration::Registration.new attendee, false, {}, [], []
        r.register_plans.respond_to?(:each).should be_true
      end

      context "disabled plans" do
        let(:remove_dsbl_msg) { "One of the plans you tried to remove (#{dsbl_plan.name}) has been disabled to prevent changes.  Please contact the registrar." }

        it "keeps extant disabled plan" do
          attendee.plans << dsbl_plan
          ps = Registration::PlanSelection.new(dsbl_plan, 1)
          r = Registration::Registration.new attendee, false, {}, [ps], []
          r.register_plans.should be_empty
          attendee.reload.plans.should include dsbl_plan
        end

        it "does not add disabled plan" do
          ps = Registration::PlanSelection.new(dsbl_plan, 1)
          r = Registration::Registration.new attendee, false, {}, [ps], []
          expected_msg = "One of the plans you tried to select (#{dsbl_plan.name}) has been disabled to prevent changes.  Please contact the registrar."
          r.register_plans.should == [expected_msg]
          attendee.reload.plans.should_not include dsbl_plan
        end

        it "does not remove disabled plan by passing qty 0" do
          attendee.plans << dsbl_plan
          ps = Registration::PlanSelection.new(dsbl_plan, 0)
          r = Registration::Registration.new attendee, false, {}, [ps], []
          r.register_plans.should == [remove_dsbl_msg]
          attendee.reload.plans.should include dsbl_plan
        end

        it "does not remove disabled plan by passing empty array" do
          attendee.plans << dsbl_plan
          r = Registration::Registration.new attendee, false, {}, [], []
          r.register_plans.should == [remove_dsbl_msg]
          attendee.reload.plans.should include dsbl_plan
        end
      end

      context "when there is a mandatory category" do
        let!(:mandatory_category) { create :plan_category, :mandatory => true }

        it 'returns an error if no plan is selected' do
          r = Registration::Registration.new attendee, false, {}, [], []
          r.register_plans.should include("Please select at least one plan in #{mandatory_category.name}")
        end

        it 'returns an error if only selection has qty of zero' do
          plan = create :plan, :plan_category => mandatory_category
          ps = Registration::PlanSelection.new plan, 0
          r = Registration::Registration.new attendee, false, {}, [ps], []
          r.register_plans.should include("Please select at least one plan in #{mandatory_category.name}")
        end
      end
    end
  end

  context "as an admin" do
    let(:admin) { true }

    describe '#save' do
      it "adds disabled activities, and returns no errors" do
        a = build :attendee
        r = Registration::Registration.new a, admin, {}, [], [dsbl_act.id]
        expect { r.save.should be_empty
          }.to change { AttendeeActivity.count }.by(+1)
      end

      it "removes disabled activities, and returns no errors" do
        a = create :attendee
        a.activities << dsbl_act
        r = Registration::Registration.new a, admin, {}, [], []
        expect { r.save.should be_empty
          }.to change { AttendeeActivity.count }.by(-1)
      end
    end

    describe '#register_plans' do
      let(:attendee) { create :attendee }

      context "disabled plans" do
        it "adds disabled plan" do
          ps = Registration::PlanSelection.new(dsbl_plan, 1)
          r = Registration::Registration.new attendee, true, {}, [ps], []
          r.register_plans.should be_empty
          attendee.reload.plans.should include dsbl_plan
        end

        it "removes disabled plan" do
          attendee.plans << dsbl_plan
          r = Registration::Registration.new attendee, true, {}, [], []
          r.register_plans.should be_empty
          attendee.reload.plans.should_not include dsbl_plan
        end
      end
    end
  end
end
