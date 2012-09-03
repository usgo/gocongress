require "spec_helper"

describe Tournament do
  it_behaves_like "a yearly model"

  it "has valid factory" do
    FactoryGirl.build(:tournament).should be_valid
  end

  describe "#has_rounds" do
    it "does the obvious" do
      t = FactoryGirl.create :tournament
      t.should_not have_rounds
      FactoryGirl.create(:round, tournament: t)
      t.should have_rounds
    end
  end

end
