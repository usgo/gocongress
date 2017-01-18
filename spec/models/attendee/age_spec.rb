require "rails_helper"

RSpec.describe Attendee::Age, :type => :model do
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
      expect(arlene.years).to eq(41)
    end

    it 'returns 22 for John Doe, because his birthday is before congress' do
      john = Attendee::Age.new(Date.new(1990, 7, 5), sd)
      expect(john.years).to eq(22)
    end
  end

  describe '#birthday_after_congress?' do
    it 'returns true if birthday occurs after congress start date' do
      jared = Attendee::Age.new(Date.new(1981, 9, 10), sd)
      expect(jared.birthday_after_congress?).to eq(true)
    end

    it 'returns false if birthday occurs before congress start date' do
      john = Attendee::Age.new(Date.new(1990, 7, 5), sd)
      expect(john.birthday_after_congress?).to eq(false)
    end

    it 'returns false if birthday falls on the congress start date' do
      jane = Attendee::Age.new(Date.new(2000, sd.month, sd.day), sd)
      expect(jane.birthday_after_congress?).to eq(false)
    end
  end

  describe '#minor?' do
    it 'John will be 18' do
      john = Attendee::Age.new(Date.new(1994, 7, 5), sd)
      expect(john).not_to be_minor
    end

    it 'Jane will be 17' do
      jane = Attendee::Age.new(Date.new(1994, 10, 1), sd)
      expect(jane).to be_minor
    end
  end
end
