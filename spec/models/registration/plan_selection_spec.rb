require "rails_helper"

RSpec.describe Registration::PlanSelection, :type => :model do
  let(:plan) { create(:plan) }
  let(:dates) { ['2013-08-06', '2013-08-07'] }

  describe '.parse_params' do
    subject { Registration::PlanSelection }
    let(:another_plan) { create(:plan) }
    let(:daily_plan) { create(:plan, daily: true) }
    let(:disabled_plan) { create(:plan, disabled: true) }
    let(:plans) { [plan, another_plan, daily_plan, disabled_plan] }

    it 'builds an array of selections from the params' do
      plan_parms = {
        plan.id.to_s => { 'qty' => 2 },
        daily_plan.id.to_s => { 'qty' => 1, 'dates' => dates },
        '12345' => { 'qty' => 42 },
        disabled_plan.id.to_s => { 'qty' => '13' }
      }
      result = subject.parse_params(plan_parms, plans)
      expect(result.count).to eq(plans.count)
      expect(result.map(&:plan)).to match_array(plans)
      expect(result.map{|s| s.qty}).to match_array([0,1,2,13])
      daily_plan_sln = result.select{|s| s.plan.id == daily_plan.id}.first
      parsed_dates = dates.map { |d| Date.parse(d) }
      expect(daily_plan_sln.dates).to match_array(parsed_dates)
      expect(result).to match_array([
        ps(plan, 2),
        ps(daily_plan, 1, parsed_dates),
        ps(another_plan, 0),
        ps(disabled_plan, 13)
      ])
    end
  end

  describe '#==' do
    it 'compares plan id, qty, and dates' do
      expect(ps(plan, 1)).to eq(ps(plan, 1))
      expect(ps(plan, 1, dates)).to eq(ps(plan, 1, dates))
      expect(ps(plan, 1)).not_to eq(ps(plan, 3))
      expect(ps(plan, 1, [])).not_to eq(ps(plan, 1, [double]))
    end
  end

  def ps(plan, qty, dates = [])
    Registration::PlanSelection.new(plan, qty, dates)
  end
end
