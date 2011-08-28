require 'test_helper'

class TournamentsControllerTest < ActionController::TestCase

  test "visitor can get index" do
    get :index, :year => Time.now.year
    assert_response :success
  end

  test "index has expected tournaments and rounds" do
    t = Factory.create(:tournament, :year => Time.now.year, :name => "Crazy Go")
    get :index, :year => Time.now.year
    assert_equal 1, assigns(:tournaments).length
    
    assert assigns(:rounds_by_date).present?
    total_rounds = assigns(:rounds_by_date).values.flatten.length
    assert_equal t.rounds.count, total_rounds
  end

end
