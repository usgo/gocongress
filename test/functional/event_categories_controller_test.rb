require 'test_helper'

class EventCategoriesControllerTest < ActionController::TestCase
  setup do
    @ec = Factory(:event_category)
  end

  test "anyone can show" do
    get :show, :year => Time.now.year, :id => @ec
    assert_not_nil assigns[:activities_by_date]
    assert_response :success
  end

end
