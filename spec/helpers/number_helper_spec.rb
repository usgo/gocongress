# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NumberHelper do
  it 'returns the expected String' do
    expect(usgc_pluralize(1, 'user')).to eq("one user")
    expect(usgc_pluralize(2, 'user')).to eq("two users")
    expect(usgc_pluralize(9, 'user')).to eq("nine users")
    expect(usgc_pluralize(10, 'user')).to eq("10 users")
    expect(usgc_pluralize(1.3, 'banana')).to eq("1.3 bananas")
  end
end
