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
      plan_parms = {
        plan.id.to_s => { 'qty' => 2 },
        daily_plan.id.to_s => { 'qty' => 1, 'dates' => dates },
        '12345' => { 'qty' => 42 }
      }
      result = subject.parse_params(plan_parms, plans)
      result.count.should == plans.count
      result.map(&:plan).should =~ plans
      result.map{|s| s.qty}.should =~ [0,1,2]
      daily_plan_sln = result.select{|s| s.plan.id == daily_plan.id}.first
      parsed_dates = dates.map { |d| Date.parse(d) }
      daily_plan_sln.dates.should =~ parsed_dates
      result.should =~ [
        ps(plan, 2),
        ps(daily_plan, 1, parsed_dates),
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
