require "rails_helper"

RSpec.describe Tournament, :type => :model do
  it_behaves_like "a yearly model"

  it "has valid factory" do
    expect(build(:tournament)).to be_valid
  end
end
