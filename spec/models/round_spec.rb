require 'rails_helper'

RSpec.describe Round, type: :model do
  before(:each) do
    tournament = create(:tournament)
    @round_one = create(:round, number: 1, tournament: tournament)
    @round_two = build_stubbed(:round, number: 1, tournament: tournament)
  end

  it "has a valid factory" do
    expect(build(:round)).to be_valid
  end

  it 'a round is not valid with the same number and tournament' do
    expect(@round_one).to be_valid
    expect(@round_two).to_not be_valid

  end



end
