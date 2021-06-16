require "rails_helper"

RSpec.describe Year, :type => :model do
  it 'has a valid factory' do
    expect(build(:year)).to be_valid
  end

  describe '#online?' do
    it 'is based on the enum' do
      year = build :year, event_type: 'online'
      expect(year.online?).to eq(true)
      expect(year.in_person?).to eq(false)
    end
  end
end
