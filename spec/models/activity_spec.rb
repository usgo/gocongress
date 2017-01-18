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
  end
end
