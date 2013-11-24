class AttendeesController < ApplicationController
  include YearlyController

  # Callbacks, in order
  before_filter :require_authentication, :except => [:index, :vip]
  add_filter_restricting_resources_to_year_in_route

  def index
    @who_is_coming = Attendee::WhoIsComing.new @year, params[:sort], params[:direction]
  end

  def print_summary
    @attendee = Attendee.find params[:id]
    authorize! :read, @attendee
    @attendee_attr_names = %w[aga_id birth_date comment email gender phone special_request roomate_request].sort
    render :layout => "print"
  end

  def vip
    @attendees = Attendee.yr(@year).where('rank >= 101').order('rank desc')
  end
end
