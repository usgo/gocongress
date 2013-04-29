require_relative '../../app/services/plan_calendar'

describe PlanCalendar do
  let(:range) { (Date.new(2013, 8, 2) .. Date.new(2013, 8, 12)) }

  describe '.range_to_matrix' do
    it 'returns a matrix representing a calendar' do
      range.should have(11).days
      m = PlanCalendar.range_to_matrix(range)
      m.should respond_to :each
      m.should have(3).rows # three calendric weeks
      m[0].should have(7).days
      m[0].compact.should have(2).days # Fri, Sat
      m[1].compact.should have(7).days # All week
      m[2].compact.should have(2).days # Sun, Mon
    end
  end
end
