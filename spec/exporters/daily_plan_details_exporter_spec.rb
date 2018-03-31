require "rails_helper"

RSpec.describe DailyPlanDetailsExporter do
  let(:p1) { create :plan, daily: true, name: 'Plan 1' }
  let(:p2) { create :plan, daily: true, name: 'Plan 2' }
  let(:year) { Date.current.year }
  let(:range) { AttendeePlanDate.valid_range(year) }
  let(:exporter) { DailyPlanDetailsExporter.new(year, range) }

  describe '#header' do
    it 'has one col per day' do
      expect(exporter.header).to eq(
        %w[user_id attendee_id family_name given_name alternate_name plan_name] +
        range.map { |d| d.strftime('%-m/%-d') }
      )
    end
  end

  describe '#to_matrix' do
    it 'return one row per attendee, one col per day' do
      a1 = create :attendee, alternate_name: 'Alternate Name'
      a2 = create :attendee
      ap1 = create :attendee_plan, plan: p1, attendee: a1
      ap2 = create :attendee_plan, plan: p1, attendee: a2
      ap3 = create :attendee_plan, plan: p2, attendee: a1
      ap4 = create :attendee_plan, plan: p2, attendee: a2
      dates = range.to_a
      create :attendee_plan_date, :attendee_plan => ap1, :_date => dates[0]
      create :attendee_plan_date, :attendee_plan => ap2, :_date => dates[1]
      create :attendee_plan_date, :attendee_plan => ap3, :_date => dates[0]
      create :attendee_plan_date, :attendee_plan => ap4, :_date => dates[1]
      zeros = Array.new(dates.length - 2, 0)
      expect(exporter.to_matrix).to eq(
        [exporter.header] + [
          [a1.user_id, a1.id, a1.family_name, a1.given_name, a1.alternate_name, p1.name, 1, 0] + zeros,
          [a2.user_id, a2.id, a2.family_name, a2.given_name, a2.alternate_name, p1.name, 0, 1] + zeros,
          [a1.user_id, a1.id, a1.family_name, a1.given_name, a1.alternate_name, p2.name, 1, 0] + zeros,
          [a2.user_id, a2.id, a2.family_name, a2.given_name, a2.alternate_name, p2.name, 0, 1] + zeros
        ])
    end
  end
end

