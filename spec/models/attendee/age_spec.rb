require "spec_helper"

describe Attendee::Age do
  let(:sd) { Year.find_by_year(2012).start_date }

  describe '.new' do
    it 'takes two non-nil arguments' do
      expect { Attendee::Age.new }.to raise_error(ArgumentError)
      expect { Attendee::Age.new(nil) }.to raise_error(ArgumentError)
      expect { Attendee::Age.new(nil, nil) }.to raise_error(ArgumentError)
      expect { Attendee::Age.new(double, double) }.to_not raise_error
    end
  end

  describe '#years' do
    it 'returns 41 for Arlene because her birthday is after congress' do
      arlene = Attendee::Age.new(Date.new(1970, 9, 22), sd)
      arlene.years.should == 41
    end

    it 'returns 22 for John Doe, because his birthday is before congress' do
      john = Attendee::Age.new(Date.new(1990, 7, 5), sd)
      john.years.should == 22
    end
  end

  describe '#birthday_after_congress?' do
    it 'returns true if birthday occurs after congress start date' do
      jared = Attendee::Age.new(Date.new(1981, 9, 10), sd)
      jared.birthday_after_congress?.should == true
    end

    it 'returns false if birthday occurs before congress start date' do
      john = Attendee::Age.new(Date.new(1990, 7, 5), sd)
      john.birthday_after_congress?.should == false
    end

    it 'returns false if birthday falls on the congress start date' do
      jane = Attendee::Age.new(Date.new(2000, sd.month, sd.day), sd)
      jane.birthday_after_congress?.should == false
    end
  end

  describe '#minor?' do
    it 'John will be 18' do
      john = Attendee::Age.new(Date.new(1994, 7, 5), sd)
      john.should_not be_minor
    end

    it 'Jane will be 17' do
      jane = Attendee::Age.new(Date.new(1994, 10, 1), sd)
      jane.should be_minor
    end
  end
end
