class HomeController < ApplicationController

	def index
		@bodyClassList = "homepage"		
		@arSlideTitles = [ \
			"A view of the UCSB campus from the ocean" \
			, "The main playing area: Corwin Pavillion, lying at the heart of campus, is steps away from the dorms, Youth room, dining hall, and the Lagoon" \
			, "A view across the Lagoon of the University Center, housing the main playing area" \
			, "Beautifully manicured bike paths provide access to campus facilities, as well as to nearby off-campus amenities" \
			, "The view inland from campus" \
			, "Santa Barbara city-scape from the courthouse tower" \
			, "The historic Santa Barbara Mission" \
			, "The beach at UCSB" \
			, "Aerial view of the UCSB campus" \
			]
			
		# Just playing around, I may not keep this welcome message -Jared
		if (current_user && current_user.primary_attendee)
			@welcomeMessage = "Welcome, " + current_user.primary_attendee.given_name
		else
			@welcomeMessage = ""
		end
	end

	def access_denied
	end

end
