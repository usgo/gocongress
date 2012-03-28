require 'test_helper'

class TournamentTest < ActiveSupport::TestCase
  test "factory is valid" do
    assert FactoryGirl.build(:tournament).valid?
  end
end
