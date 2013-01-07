require "spec_helper"

describe AttendeePlanDate do

  it 'has a valid factory' do
    build(:attendee_plan_date).should be_valid
  end

  describe '#valid?' do
    it 'requires an AttendeePlan' do
      subject.attendee_plan = nil
      subject.should_not be_valid
      subject.errors.should have_key :attendee_plan
    end

    it 'requires a date' do
      subject._date = nil
      subject.should_not be_valid
      subject.errors.should have_key :_date
    end

  end
end
