class HomeController < ApplicationController

  def index
    @bodyClassList = "homepage"
    @slides = SlideSet.new(@year.year).slides_as_arrays

    if @year.year == 2011
      @venue_url = 'http://www.ucsb.edu'
      @venue_name = 'University of California, Santa Barbara'
      @venue_address = '552 University Road'
      @venue_city_state_zip = 'Santa Barbara CA, 93106'
    else
      @venue_url = 'http://g.co/maps/agyb5'
      @venue_name = 'Blue Ridge Assembly'
      @venue_address = nil
      @venue_city_state_zip = 'Black Mountain, NC 28711'
    end

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
