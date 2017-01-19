require "rails_helper"

RSpec.describe Event, :type => :model do
  it_behaves_like "a yearly model"

  it "has a valid factory" do
    expect(build(:event)).to be_valid
  end
end

