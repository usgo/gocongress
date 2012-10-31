require "spec_helper"

describe Tournament do
  it_behaves_like "a yearly model"

  it "has valid factory" do
    build(:tournament).should be_valid
  end

  describe "#has_rounds" do
    it "does the obvious" do
      t = create :tournament
      t.should_not have_rounds
      create(:round, tournament: t)
      t.should have_rounds
    end
  end

end
