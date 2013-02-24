require "spec_helper"

describe Tournament do
  it_behaves_like "a yearly model"

  it "has valid factory" do
    build(:tournament).should be_valid
  end
end
