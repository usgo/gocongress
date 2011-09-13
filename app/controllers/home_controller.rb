class HomeController < ApplicationController

  def index
    @bodyClassList = "homepage"
    if @year == 2011
      @slides = [ \
        ["UCSB campus", "A view of the UCSB campus from the ocean"] \
        , ["The main playing area", "Corwin Pavillion, lying at the heart of campus, is steps away from the dorms, Youth room, dining hall, and the Lagoon"] \
        , ["A view across the Lagoon", "A view across the Lagoon of the University Center, housing the main playing area"] \
        , ["Bike paths", "Beautifully manicured bike paths provide access to campus facilities, as well as to nearby off-campus amenities"] \
        , ["The view inland from campus", ""] \
        , ["Santa Barbara", "City-scape from the courthouse tower"] \
        , ["The historic Santa Barbara Mission", ""] \
        , ["The beach at UCSB", ""] \
        , ["Aerial view of the UCSB campus", ""] \
        ]
      @venue_url = 'http://www.ucsb.edu'
      @venue_name = 'University of California, Santa Barbara'
      @venue_address = '552 University Road'
      @venue_city_state_zip = 'Santa Barbara CA, 93106'
    else
      @slides = [ \
        ["Lee Hall Panorama", "Bob Felice"] \
        , ["Blue Ridge Center", "Bob Felice"] \
        , ["Jimmy Tries Out a Rocker", "Bob Felice"] \
        , ["Michael, Xianxian, and Nakayama Sensei", "Bob Felice"] \
        , ["US Open Panorama", "Bob Felice"] \
        , ["Evening comes to the US Go Congress", "Roy Laird"] \
        ]
      @venue_url = 'http://www.blueridgeassembly.org/'
      @venue_name = 'YMCA Blue Ridge Assembly'
      @venue_address = '84 Blue Ridge Cir'
      @venue_city_state_zip = 'Black Mountain, NC 28711'
    end

    # Get announcements for the homepage
    contents_where_clause = "year = ? and show_on_homepage = ? and (expires_at is null or expires_at > ?)"
    @contents = Content.where(contents_where_clause, @year, true, Time.now).order("created_at desc")
  end

  def access_denied
  end

  def kaboom
    raise "Intentional error to test error handling"
  end

  def pricing
    authorize! :see_admin_menu, :layout
  end

protected

  def page_title
    human_action_name
  end

end
