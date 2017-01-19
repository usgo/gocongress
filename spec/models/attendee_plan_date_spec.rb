require "rails_helper"

RSpec.describe AttendeePlanDate, :type => :model do

  it 'has a valid factory' do
    expect(build(:attendee_plan_date)).to be_valid
  end

  describe '#valid?' do

    it 'requires an AttendeePlan' do
      expect(subject).to have_error_about :attendee_plan
    end

    it 'requires a date' do
      expect(subject).to have_error_about :_date
    end

    it 'date must be during congress' do
      d = build(:attendee_plan_date)
      d._date = CONGRESS_START_DATE[2013] - 3.days
      expect(d).to have_error_about :_date
      d._date = CONGRESS_START_DATE[2013] + 3.weeks
      expect(d).to have_error_about :_date
    end
  end
end
