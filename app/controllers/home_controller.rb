class HomeController < ApplicationController

	def index
		@bodyClassList = "homepage"
		@arSlideTitles = [ \
			"UCSB Campus" \
			, "This could be our tournament hall! (Corwin Pavilion)" \
			, "University Center and Lagoon" \
			, "UCSB Bike path" \
			, "City and Mountains" \
			, "Los Angeles?" \
			, "Santa Barbara Mission" \
			, "Beach and Mountains" \
			, "UCSB?" \
			]
	end

end
