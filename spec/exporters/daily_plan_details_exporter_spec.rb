require 'spec_helper'

describe DailyPlanDetailsExporter do
  let(:plan) { create :plan, daily: true }
  let(:year) { Date.current.year }
  let(:range) { AttendeePlanDate.valid_range(year) }
  let(:exporter) { DailyPlanDetailsExporter.new(year, range, plan.id) }

  describe '#header' do
    it 'has one col per day' do
      expect(exporter.header).to eq(
        %w[family_name given_name] +
        range.map { |d| d.strftime('%-m/%-d') }
      )
    end
  end

  describe '#to_matrix' do
    it 'return one row per attendee, one col per day' do
      a1 = create :attendee
      a2 = create :attendee
      ap1 = create :attendee_plan, plan: plan, attendee: a1
      ap2 = create :attendee_plan, plan: plan, attendee: a2
      dates = range.to_a
      create :attendee_plan_date, :attendee_plan => ap1, :_date => dates[0]
      create :attendee_plan_date, :attendee_plan => ap2, :_date => dates[1]
      falsies = Array.new(dates.length - 2, false)
      expect(exporter.to_matrix).to eq(
        [exporter.header] + [
          [a1.family_name, a1.given_name, true, false] + falsies,
          [a2.family_name, a2.given_name, false, true] + falsies
        ])
    end
  end
end

