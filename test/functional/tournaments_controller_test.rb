require 'test_helper'

class TournamentsControllerTest < ActionController::TestCase

  test "visitor can get index" do
    get :index, :year => Time.now.year
    assert_response :success
  end

  test "index has expected tournaments and rounds" do
    t = Factory.create(:tournament, :year => Time.now.year)
    x = Factory.create(:tournament, :year => 1.year.ago)
    get :index, :year => Time.now.year
    
    # we expect to see only this year's tournament and rounds
    assert_equal 1, assigns(:tournaments).length
    assert assigns(:rounds_by_date).present?
    total_rounds = assigns(:rounds_by_date).values.flatten.length
    assert_equal t.rounds.count, total_rounds
  end

end
