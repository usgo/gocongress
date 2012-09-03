require 'spec_helper'

describe Event do
  it_behaves_like "a yearly model"

  it "has a valid factory" do
    FactoryGirl.build(:event).should be_valid
  end
end

