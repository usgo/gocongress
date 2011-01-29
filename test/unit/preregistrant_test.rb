require 'test_helper'

class PreregistrantTest < ActiveSupport::TestCase
  setup do
    @preregistrant = Factory.create(:preregistrant)
  end

  test "factory is valid" do
    assert Factory.build(:preregistrant).valid?
  end

  test "test get rank name" do
    @preregistrant.ranktype = 'p'
    @preregistrant.rank = '3'
    assert_equal '3 pro', @preregistrant.get_rank_name
    @preregistrant.ranktype = 'd'
    @preregistrant.rank = '1'
    assert_equal '1 dan', @preregistrant.get_rank_name
    @preregistrant.ranktype = 'k'
    @preregistrant.rank = '35'
    assert_equal '35 kyu', @preregistrant.get_rank_name
    @preregistrant.ranktype = 'np'
    @preregistrant.rank = '3'
    assert_equal 'Non-player', @preregistrant.get_rank_name
  end

end
