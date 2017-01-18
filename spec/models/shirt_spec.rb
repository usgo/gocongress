require "rails_helper"

RSpec.describe Shirt, :type => :model do
  it_behaves_like "a yearly model"

  it "has a valid factory" do
    expect(build(:shirt)).to be_valid
  end

  describe '#destroy' do
    it "fails if any attendees have selected it" do
      s = create :shirt
      create :attendee, shirt: s, year: s.year
      expect { s.destroy }.to raise_error(ActiveRecord::DeleteRestrictionError)
    end
  end
end
