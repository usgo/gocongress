require 'test_helper'

class EventCategoriesControllerTest < ActionController::TestCase
  setup do
    @ec = Factory(:event_category)
  end

  test "anyone can show" do
    get :show, :year => Time.now.year, :id => @ec
    assert_equal false, assigns[:events_by_date].nil?
    assert_response :success
  end

end
