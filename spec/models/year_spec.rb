require "spec_helper"

describe Year do
  it 'has a valid factory' do
    build(:year).should be_valid
  end
end
