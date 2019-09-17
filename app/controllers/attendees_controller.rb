class AttendeesController < ApplicationController
  include YearlyController

  # Callbacks, in order
  before_action :require_authentication, :except => [:index, :vip]
  add_filter_restricting_resources_to_year_in_route
  load_and_authorize_resource :only => :list

  # Pagination
  PER_PAGE = 200

  def index
    @who_is_coming = Attendee::WhoIsComing.new @year, params[:sort], params[:direction]

    # Allow individual years to provide alternative, hard-coded lists of who's coming if they don't
    # use the Congress website for registration.
    render :template => "attendees/#{@year.year}/index" rescue render :template => "attendees/index"
  end

  def list
    drn = (params[:drn] == "desc") ? :desc : :asc
    if params[:sort] == "user_email"
      @attendees = Attendee.yr(@year).joins(:user).order("users.email #{drn}").page(params[:page]).per(PER_PAGE)
    elsif params[:sort] == "alternate_name"
      @attendees = Attendee.yr(@year).order("alternate_name #{drn}").page(params[:page]).per(PER_PAGE)
    else
      @attendees = Attendee.yr(@year).order("family_name #{drn}, given_name #{drn}").page(params[:page]).per(PER_PAGE)
    end
  end

  def print_summary
    @attendee = Attendee.find params[:id]
    authorize! :read, @attendee
    @attendee_attr_names = %w[aga_id country email gender phone special_request receive_sms roomate_request will_play_in_us_open].sort
    render :layout => "print"
  end

  def vip
    if @year.year != 2019 || current_user_is_admin?
      @attendees = Attendee
        .yr(@year)
        .where(:cancelled => false)
        .where('rank >= 101')
        .order('rank desc')
    else
      redirect_to year_path
    end
  end
end
