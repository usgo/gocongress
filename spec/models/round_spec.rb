require 'rails_helper'

RSpec.describe Round, type: :model do
  it "has a valid factory" do
    expect(build(:round)).to be_valid
  end


end
