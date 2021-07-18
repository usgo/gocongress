require "rails_helper"

RSpec.describe Activity, :type => :model do
  it_behaves_like "a yearly model"

  it "has a valid factory" do
    expect(build(:activity)).to be_valid
  end

  context "when initialized" do
    subject { Activity.new }
    it "is enabled" do
      is_expected.not_to be_disabled
    end
  end

  describe '#valid?' do
    it 'validates format of url' do
      expect(build(:activity, url: 'www.seafair.com/')).not_to be_valid
      expect(build(:activity, url: 'http://www.seafair.com/')).to be_valid
      expect(build(:activity, url: 'https://www.seafair.com/')).to be_valid
      expect(build(:activity, url: nil)).to be_valid
    end

    it 'validates price is integer' do
      act = build(:activity, price: 1.50)
      expect(act).to be_invalid
      expect(act.errors[:price]).to(
        match_array(['must be an integer'])
      )
    end

    context 'when price_varies' do
      it 'must have price of 0' do
        act = build(:activity, price: 0, price_varies: true)
        expect(act).to be_valid
        act.price = 7
        act.validate
        expect(act.errors[:price]).to(
          match_array([a_string_including('You have indicated that the price varies')])
        )
      end
    end
  end
end
