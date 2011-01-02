class AttendeeController < ApplicationController

  def index
  	@attendees = Attendee.all
  end

end
