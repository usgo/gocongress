class CheckInController < ApplicationController
  include YearlyController

  # Access Control
  before_action :deny_users_from_wrong_year
  before_action :authorize_check_in

  def authorize_check_in() authorize! :check_in, :attendee end

  helper_method :cleared_to_check_in

  # Actions
  def index
    @not_checked_in_attendees = Attendee.yr(@year)
      .where(:checked_in => false, :cancelled => false)
      .order(:family_name)

    @checked_in_attendees = Attendee.yr(@year)
      .where(:checked_in => true, :cancelled => false)
      .order(:family_name)
  end

  def show
    @attendee = Attendee.yr(@year).find(params[:id])
    @aga_info = AgaTdList.data(@attendee.aga_id)
    @current_aga = AgaTdList.current(@attendee.aga_id)
    @user = @attendee.user

    @balance = @user.balance

    @cleared = cleared_to_check_in(@attendee)
  end

  def check_in_attendee
    @attendee = Attendee.yr(@year).find(params[:attendee_id])

    # Convert string to a boolean
    checked_in = params[:checked_in] == 'true' ? true : false

    @attendee.update(checked_in: checked_in)

    # TODO: color code notice?
    redirect_to(check_in_path, :notice => "#{@attendee.full_name} has been checked #{checked_in ? "in" : "out"}.")
  end

  private

  # Check an attendee for all the requirements to check in
  def cleared_to_check_in(attendee)
    # Presume success, then check for failures
    cleared = true

    # Check for outstanding balance
    if (attendee.user.balance != 0)
      cleared = false
    end

    # Check for AGA ID
    if (!attendee.aga_id)
      #TODO Check for validity?
      cleared = false
    end

    # Check for current AGA Membership
    if (!AgaTdList.current(attendee.aga_id))
      cleared = false
    end

    # Check for minor_agreement_received
    if (attendee.minor?)
      cleared = attendee.minor_agreement_received;
    end

    cleared
  end

  protected

  def page_title
    "Check In"
  end
end
