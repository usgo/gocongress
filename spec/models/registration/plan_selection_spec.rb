require 'spec_helper'

describe Registration::PlanSelection do
  let(:plan) { create(:plan) }
  let(:dates) { ['2013-08-06', '2013-08-07'] }

  describe '.parse_params' do
    subject { Registration::PlanSelection }
    let(:another_plan) { create(:plan) }
    let(:daily_plan) { create(:plan, daily: true) }
    let(:plans) { [plan, another_plan, daily_plan] }

    it 'builds an array of selections from the params' do
      parms = {
        "plan_#{plan.id}_qty" => 2,
        "plan_#{daily_plan.id}_qty" => 1,
        "plan_#{daily_plan.id}_dates" => dates,
        "plan_12345_qty" => 42
      }
      result = subject.parse_params(parms, plans)
      result.should have(3).selections
      result.map(&:plan).should =~ plans
      result.map{|s| s.qty}.should =~ [0,1,2]
      result.select{|s| s.plan.id == daily_plan.id}.first.dates.should == dates
      result.should =~ [
        ps(plan, 2),
        ps(daily_plan, 1, dates),
        ps(another_plan, 0)
      ]
    end
  end

  describe '#==' do
    it 'compares plan id, qty, and dates' do
      ps(plan, 1).should == ps(plan, 1)
      ps(plan, 1, dates).should == ps(plan, 1, dates)
      ps(plan, 1).should_not == ps(plan, 3)
      ps(plan, 1, []).should_not == ps(plan, 1, [double])
    end
  end

  def ps(plan, qty, dates = [])
    Registration::PlanSelection.new(plan, qty, dates)
  end
end
