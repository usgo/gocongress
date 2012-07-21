class HomeController < ApplicationController

  def index
    @bodyClassList = "homepage"
    @slides = SlideSet.new(@year.year).slides_as_arrays

    # Get announcements for the homepage
    contents_where_clause = "year = ? and show_on_homepage = ? and (expires_at is null or expires_at > ?)"
    @contents = Content.where(contents_where_clause, @year.year, true, Time.now).order("created_at desc")
  end

  def access_denied
  end

  def kaboom
    raise "Intentional error to test runtime exception notification"
  end

  def pricing
    authorize! :see_admin_menu, :layout
  end

protected

  def page_title
    human_action_name
  end

end
