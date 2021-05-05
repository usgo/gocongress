class RegistrationsController < ApplicationController
  before_action :require_authentication, :except => [:index, :vip]

  def new
    attendee = Attendee.new
    attendee.user = User.find(params[:user_id] || current_user.id)
    attendee.year = @year.year
    @registration = Registration.new(current_user, attendee)
    expose_legacy_form_vars # TODO: don't!

    if params.has_key?(:aga_id)
      # Get member info from the API
      apiUrl = "https://www.usgo.org/mm/api/members/"
      action = "#{params[:aga_id]}?api_key=#{ENV['AGA_MEMBERS_API_KEY']}"

      begin
        buffer = open("#{apiUrl}#{action}").read
        result = JSON.parse(buffer)

        if result['success']
          # Pre-fill attendee values with AGA Member Info
          i = result['payload']['row']
          attendee.given_name = i['given_names']
          attendee.family_name = i['family_name']

          # Grab the first letter of gender
          # Ex: 'female' => 'f'
          attendee.gender = i['gender'][0] rescue ''

          attendee.birth_date = i['dob']
          attendee.aga_id = i['member_id']
          attendee.phone = i['phone']
          attendee.local_phone = i['phone']
          attendee.email = i['email']
          attendee.state = i['state']

          # Minimum rating is -30 (30k)
          attendee.rank = [i['rating'].to_i, -30].max.to_s

          if (i['country'] == 'USA')
            attendee.country = 'US'
          else
            # Try to get the country code from the site constants
            found = COUNTRIES.detect {|country| country[0] == i['country']}
            if found
              attendee.country = found[1]
            end
          end
        end

        rescue OpenURI::HTTPError
          # No worries! We just won't pre-fill any values.
      end

      render :new
    else
      render :aga_member_search
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
