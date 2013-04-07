class HomeController < ApplicationController

  def index
    @bodyClassList = "homepage"
    @slides = SlideSet.new(@year.year).slides_as_arrays
    @contents = Content.yr(@year).homepage.unexpired.newest_first
    @years = 2011..LATEST_YEAR
    @logo_file = logo_file(@year)
  end

  def access_denied
  end

  def kaboom
    raise "Intentional error to test runtime exception notification"
  end

protected

  def page_title
    human_action_name
  end

  private

  def logo_file year
    year.to_i == 2013 ? '2013.jpg' : "#{@year.year}.png"
  end

end
