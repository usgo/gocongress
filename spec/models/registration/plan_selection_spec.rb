require 'spec_helper'

describe Registration::PlanSelection do
  let(:plan) { create(:plan) }

  describe '.parse_params' do
    subject { Registration::PlanSelection }
    let(:another_plan) { create(:plan) }
    let(:daily_plan) { create(:plan, daily: true) }
    let(:plans) { [plan, another_plan, daily_plan] }

    it 'builds an array of selections from the params' do
      parms = {
        "plan_#{plan.id}_qty" => 1,
        "plan_#{daily_plan.id}_qty" => 2
      }
      result = subject.parse_params(parms, plans)
      result.should have(3).selections
      result.map(&:plan).should =~ plans
      result.map{|s| s.qty}.should =~ [0,1,2]
      result.should =~ [
        Registration::PlanSelection.new(plan, 1),
        Registration::PlanSelection.new(daily_plan, 2),
        Registration::PlanSelection.new(another_plan, 0)
      ]
    end
  end

  describe '#==' do
    it 'compares plan id and qty' do
      a = Registration::PlanSelection.new(plan, 1)
      b = Registration::PlanSelection.new(plan, 1)
      a.should == b
      c = Registration::PlanSelection.new(plan, 3)
      a.should_not == c
    end
  end
end
