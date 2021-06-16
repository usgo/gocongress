require "rails_helper"

RSpec.describe Tournament, :type => :model do
  it_behaves_like "a yearly model"

  it "has valid factory" do
    expect(build(:tournament)).to be_valid
  end

  describe '#online?' do
    it 'is based on the enum' do
      year = build :tournament, event_type: 'online'
      expect(year.online?).to eq(true)
      expect(year.in_person?).to eq(false)
    end
  end
end
