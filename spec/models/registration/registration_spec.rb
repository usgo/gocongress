require 'spec_helper'

describe Registration::Registration do
  let(:dsbl_act) { create :activity, disabled: true }

  context "not an admin" do
    let(:admin) { false }

    describe '#save' do
      it "does not add disabled activity, and returns an error" do
        a = build :attendee
        p = {:activity_ids => [dsbl_act.id]}
        r = Registration::Registration.new a, admin, p, []
        expect { r.save.should_not be_empty
          }.to_not change { AttendeeActivity.count }
      end

      it "does not remove disabled activity, and returns an error" do
        a = create :attendee, :activities => [dsbl_act]
        p = {:activity_ids => []}
        r = Registration::Registration.new a, admin, p, []
        expect { r.save.should_not be_empty
          }.to_not change { AttendeeActivity.count }
      end
    end

    describe '#register_plans' do
      let(:attendee) { build :attendee }
      subject { Registration::Registration.new attendee, false, {}, [] }

      it 'returns something enumerable' do
        errs = subject.register_plans []
        errs.respond_to?(:each).should be_true
      end

      context "when there is a mandatory category" do
        let!(:mandatory_category) { create :plan_category, :mandatory => true }

        it 'returns an error if no plan is selected' do
          errs = subject.register_plans []
          errs.should_not be_empty
          errs.should include("Please select at least one plan in #{mandatory_category.name}")
        end

        it 'returns an error if only selection has qty of zero' do
          plan = create :plan, :plan_category => mandatory_category
          selection = Registration::PlanSelection.new plan, 0
          errs = subject.register_plans [selection]
          errs.should_not be_empty
          errs.should include("Please select at least one plan in #{mandatory_category.name}")
        end
      end
    end
  end

  context "as an admin" do
    let(:admin) { true }

    describe '#save' do
      it "adds disabled activities, and returns no errors" do
        a = build :attendee
        p = {:activity_ids => [dsbl_act.id]}
        r = Registration::Registration.new a, admin, p, []
        expect { r.save.should be_empty
          }.to change { AttendeeActivity.count }.by(+1)
      end

      it "removes disabled activities, and returns no errors" do
        a = create :attendee, :activities => [dsbl_act]
        p = {:activity_ids => []}
        r = Registration::Registration.new a, admin, p, []
        expect { r.save.should be_empty
          }.to change { AttendeeActivity.count }.by(-1)
      end
    end
  end
end
