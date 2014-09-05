require "spec_helper"

describe Year, :type => :model do
  it 'has a valid factory' do
    expect(build(:year)).to be_valid
  end
end
