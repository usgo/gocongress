require_relative '../../app/services/plan_calendar'

RSpec.describe PlanCalendar do
  let(:range) { (Date.new(2013, 8, 2) .. Date.new(2013, 8, 12)) }

  describe '.range_to_matrix' do
    it 'returns a matrix representing a calendar' do
      expect(range.count).to eq(11)
      m = PlanCalendar.range_to_matrix(range)
      expect(m).to respond_to :each
      expect(m.size).to eq(3) # three calendric weeks
      expect(m[0].size).to eq(7)
      expect(m[0].compact.size).to eq(2) # Fri, Sat
      expect(m[1].compact.size).to eq(7) # All week
      expect(m[2].compact.size).to eq(2) # Sun, Mon
    end
  end
end
