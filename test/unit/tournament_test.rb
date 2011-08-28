require 'test_helper'

class TournamentTest < ActiveSupport::TestCase
  test "factory is valid" do
    assert Factory.build(:tournament).valid?
  end
end
