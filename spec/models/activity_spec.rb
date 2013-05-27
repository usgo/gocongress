require "spec_helper"

describe Activity do
  it_behaves_like "a yearly model"

  it "has a valid factory" do
    build(:activity).should be_valid
  end

  context "when initialized" do
    subject { Activity.new }
    it "is enabled" do
      should_not be_disabled
    end
  end

  describe '#valid?' do
    it 'validates format of url' do
      build(:activity, url: 'www.seafair.com/').should_not be_valid
      build(:activity, url: 'http://www.seafair.com/').should be_valid
      build(:activity, url: 'https://www.seafair.com/').should be_valid
      build(:activity, url: nil).should be_valid
    end
  end
end
