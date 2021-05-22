class RegistrationsController < ApplicationController
  before_action :require_authentication, :except => [:index, :vip]

  def new
    user = User.find(params[:user_id] || current_user.id)
    aga_id = params[:aga_id].presence
    attendee = build_attendee(user, aga_id)
    @registration = Registration.new(current_user, attendee)
    if aga_id.nil?
      render :aga_member_search
    else
      expose_legacy_form_vars # TODO: don't!
      render :new
    end
  end

  def create
    attendee = Attendee.new
    attendee.user = User.find(params[:user_id] || current_user.id)
    attendee.year = @year.year
    authorize! :create, attendee
    @registration = Registration.new(current_user, attendee)
    expose_legacy_form_vars # TODO: don't!
    if @registration.submit(params)
      redirect_to_terminus 'Attendee added'
    else
      render :new
    end
  end

  def edit
    attendee = Attendee.find(params[:id])
    authorize! :edit, attendee
    @registration = Registration.new(current_user, attendee)
    expose_legacy_form_vars # TODO: don't!
  end

  def update
    attendee = Attendee.find(params[:id])
    authorize! :update, attendee
    @registration = Registration.new(current_user, attendee)
    expose_legacy_form_vars # TODO: don't!
    if @registration.submit(params)
      if attendee.cancelled?
        attendee.update(cancelled: false)
        redirect_to_terminus 'Restored attendee.'
      else
        redirect_to_terminus 'Changes saved'
      end
    else
      render :edit
    end
  end

  private

  # `aga_id` will be nil on the first visit to `#new`. Next, either they enter
  # an integer id, or they click "not an AGA member" and thus 'none'.
  def build_attendee(user, aga_id)
    if aga_id.nil? || aga_id == 'none'
      Attendee.new(user: user, year: @year.year)
    else
      AGA::MM::BuildAttendee.new(user, @year, aga_id.to_i).build
    end
  end

  def expose_legacy_form_vars
    @plan_calendar = PlanCalendar.range_to_matrix(AttendeePlanDate.valid_range(@year))
    @cbx_name = "plans[plan.id][dates][]"
    @show_availability = @registration.show_availability
  end

  def redirect_to_terminus flash_notice
    flash[:notice] = flash_notice
    redirect_to user_terminus_path(:user_id => @registration.user_id)
  end
end
