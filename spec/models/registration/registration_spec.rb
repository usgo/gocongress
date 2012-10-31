require 'spec_helper'

describe Registration::Registration do
  let(:attendee) { build :attendee }
  let(:coin_toss) { [true, false].sample }
  subject { Registration::Registration.new attendee, coin_toss }

  describe '#register_plans' do

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
