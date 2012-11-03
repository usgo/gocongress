class AttendeesController < ApplicationController
  include YearlyController

  # Callbacks, in order
  before_filter :require_authentication, :except => [:index, :vip]
  load_resource
  skip_load_resource :only => [:index, :vip]
  add_filter_to_set_resource_year
  authorize_resource
  skip_authorize_resource :only => [:create, :index, :vip]
  add_filter_restricting_resources_to_year_in_route
  before_filter :expose_plans, :only => [:create, :edit, :new, :update]

  def index
    params[:direction] ||= "asc"
    @opposite_direction = (params[:direction] == 'asc') ? 'desc' : 'asc'
    @attendees = Attendee.yr(@year).with_at_least_one_plan
    @attendees = @attendees.order parse_order_clause_params
    @pro_count = @attendees.pro.count
    @dan_count = @attendees.dan.count
    @kyu_count = @attendees.kyu.count
  end

  # GET    /:year/attendees/new
  # GET    /:year/users/:id/attendees/new
  def new

    # Which user are we adding this new attendee to?
    target_user_id = params[:id].present? ? params[:id].to_i : current_user.id
    target_user = User.find(target_user_id)

    # Only admins can add attendees to other users
    if !current_user.is_admin? && target_user_id != current_user.id then
      render_access_denied
      return
    end

    # Instantiate a blank attendee for the target user
    @attendee.user_id = target_user.id

    # Will this be the primary attendee?
    @attendee.is_primary = (target_user.attendees.count == 0)

    # The default email always comes from the target user
    @attendee.email = target_user.email

    # Copy certain fields from the target user's primary_attendee
    if target_user.primary_attendee.present?
      fields_to_copy = ['phone','address_1','address_2','city','state','zip','country','phone']
      fields_to_copy.each do |f|
        @attendee[f] = target_user.primary_attendee[f]
      end
    end

    expose_form_vars
  end

  def create
    params[:attendee] ||= {}
    params[:attendee][:activity_ids] ||= []

    @attendee.user_id ||= current_user.id
    @attendee.is_primary = @attendee.user.attendees.count == 0
    authorize! :create, @attendee

    errors = register_attendee
    @attendee.errors[:base].concat(errors) unless errors.empty?

    if @attendee.errors.empty?
      redirect_to_terminus 'Attendee added'
    else
      render_form :new
    end
  end

  def edit
    expose_form_vars
  end

  def update
    params[:attendee] ||= {}
    params[:attendee][:activity_ids] ||= []

    errors = register_attendee
    @attendee.errors[:base].concat(errors) unless errors.empty?

    if @attendee.errors.empty?
      redirect_to_terminus 'Changes saved'
    else
      render_form :edit
    end
  end

  def destroy
    @attendee.destroy
    redirect_to user_path(@attendee.user_id), :notice => "Attendee deleted"
  end

  def print_summary
    @attendee = Attendee.find params[:id]
    authorize! :read, @attendee
    @attendee_attr_names = %w[aga_id birth_date comment email gender phone special_request roomate_request].sort
    render :layout => "print"
  end

  def print_badge
    @attendee = Attendee.find params[:id]
    authorize! :read, @attendee
    render :layout=> 'print'
  end

  def vip
    @attendees = Attendee.yr(@year).where('rank >= 101').order('rank desc')
  end

protected

  def expose_form_vars
    raise "Attendee undefined" if @attendee.nil?
    @attendee_number = @attendee.user.attendees.count + 1

    # for _travel_plans
    arrival = @attendee.airport_arrival
    @airport_arrival_date = arrival.present? ? arrival.to_date : nil
    @airport_arrival_time = arrival.present? ? arrival.to_s(:american).strip : nil
    @airport_arrival_date_rfc822 = arrival.present? ? arrival.to_date.to_s(:rfc822) : @year.start_date.to_s(:rfc822)
    departure = @attendee.airport_departure
    @airport_departure_date = departure.present? ? departure.to_date : nil
    @airport_departure_time = departure.present? ? departure.to_s(:american).strip : nil
    @airport_departure_date_rfc822 = departure.present? ? departure.to_date.to_s(:rfc822) : @year.peak_departure_date.to_s(:rfc822)

    # for _wishes
    @discounts = Discount.yr(@year).automatic(false)
    @attendee_discount_ids = @attendee.discounts.automatic(false).map { |d| d.id }

    # for _activities
    @activities = Activity.yr(@year).order(:leave_time, :name)
    @atnd_activity_ids = @attendee.activities.map {|e| e.id}
  end

  def allow_only_self_or_admin
    allow = false
    if current_user.present?
      a = Attendee.find(params[:id].to_i)
      is_my_attendee = current_user.id.to_i == a.user_id
      allow = is_my_attendee || current_user.is_admin?
    end
    render_access_denied unless allow
  end

  private

  # `expose_plans` exposes `@plans`, determining which plans will be
  # shown on the form, and which plans are available for selection.
  # Admins can always see disabled plans, but users only see
  # disabled plans if they had already selected such a plan, eg.
  # back when it was enabled. Regardless of user level, only plans
  # appropriate to the attendee's age are shown.
  #
  # In the past we used `appropriate_for_age` but during #new we
  # don't know the attendee's age yet
  def expose_plans
    @plans = Plan.yr(@year) # todo: order
    unless current_user.admin?
      @plans.delete_if {|p| p.disabled? && !@attendee.has_plan?(p)}
    end

    @show_availability = Plan.inventoried_plan_in? @plans
    @show_quantity_instructions = Plan.quantifiable_plan_in? @plans
  end

  def get_plan_selections plans
    plans.map {|p| Registration::PlanSelection.new p, plan_qty(p.id)}
  end

  def plan_qty plan_id
    params["plan_#{plan_id}_qty"].to_i # if nil, to_i returns 0
  end

  def redirect_to_terminus flash_notice
    flash[:notice] = flash_notice
    redirect_to user_terminus_path(:user_id => @attendee.user)
  end

  # `register_attendee` tries to save `@attendee` and its associated
  # records, and returns an array of extra errors.
  def register_attendee
    reg = Registration::Registration.new(
      @attendee,
      current_user.admin?,
      params[:attendee],
      get_plan_selections(@plans))
    return reg.save
  end

  def render_form view
    expose_form_vars
    render view
  end

  # We do not want flash notices during initial registration
  def update_success_notice(page)
    %w[activities tournaments].include?(page) ? "Attendee updated" : nil
  end

  # `parse_order_clause_params` validates the supplied sort field and
  # direction, and returns an sql order clause string.  If no valid
  # sort field is supplied, the default is to sort by rank (0 is non-player).
  def parse_order_clause_params
    valid_sortable_columns = %w[given_name family_name rank created_at country]
    unless (valid_sortable_columns.include?(params[:sort]))
      order_clause = "rank = 0, rank desc"
    else
      order_clause = params[:sort]

      # sort order should be case insensitive, so we downcase certain fields
      downcased_fields = %w[given_name family_name]
      if downcased_fields.include? params[:sort]
        order_clause = "lower(#{params[:sort]})"
      end

      # some sort orders could reveal clues about anonymous people,
      # so we must first order by anonymity to protect against that.
      unsafe_for_anon = %w[given_name family_name country]
      if unsafe_for_anon.include? params[:sort]
        order_clause = 'anonymous, ' + order_clause
      end

      # sort direction
      valid_directions = %w[asc desc]
      if valid_directions.include? params[:direction]
        order_clause += " " + params[:direction]
      end
    end
  end

end
