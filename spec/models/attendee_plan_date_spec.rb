require "spec_helper"

describe AttendeePlanDate do

  it 'has a valid factory' do
    build(:attendee_plan_date).should be_valid
  end

  describe '#valid?' do

    it 'requires an AttendeePlan' do
      subject.should have_error_about :attendee_plan
    end

    it 'requires a date' do
      subject.should have_error_about :_date
    end

    it 'date must be during congress' do
      d = build(:attendee_plan_date)
      d._date = CONGRESS_START_DATE[2013] - 2.days
      d.should have_error_about :_date
      d._date = CONGRESS_START_DATE[2013] + 3.weeks
      d.should have_error_about :_date
    end
  end
end
