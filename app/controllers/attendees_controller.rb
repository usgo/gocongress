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
  before_filter :expose_selections, :only => [:create, :edit, :new, :update]

  # Constants
  DEFAULT_ORDER = 'rank = 0, rank desc'
  SORTABLE_COLUMNS = %w[given_name family_name rank created_at country]

  def index
    params[:direction] ||= "asc"
    @opposite_direction = (params[:direction] == 'asc') ? 'desc' : 'asc'
    @attendees = Attendee.yr(@year).with_at_least_one_plan
    @attendees = @attendees.order(order_clause)
    @pro_count = @attendees.pro.count
    @dan_count = @attendees.dan.count
    @kyu_count = @attendees.kyu.count
  end

  def new
    @attendee.user = User.find(params[:user_id] || current_user.id)
    @attendee.email = @attendee.user.email
    if @attendee.user.primary_attendee.present?
      ['country','phone'].each do |f|
        @attendee[f] = @attendee.user.primary_attendee[f]
      end
    else
      @attendee.is_primary = true
    end
    expose_form_vars
  end

  def create
    @attendee.is_primary = @attendee.user.primary_attendee.nil?
    authorize! :create, @attendee
    register_attendee
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
    register_attendee
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
    @attendee_number = @attendee.user.attendees.count + 1
    @activities = Activity.yr(@year).order(:leave_time, :name)

    # for _travel_plans
    arrival = @attendee.airport_arrival
    @airport_arrival_date = arrival.present? ? arrival.to_date : nil
    @airport_arrival_time = arrival.present? ? arrival.to_s(:american).strip : nil
    @airport_arrival_date_rfc822 = arrival.present? ? arrival.to_date.to_s(:rfc822) : @year.start_date.to_s(:rfc822)
    departure = @attendee.airport_departure
    @airport_departure_date = departure.present? ? departure.to_date : nil
    @airport_departure_time = departure.present? ? departure.to_s(:american).strip : nil
    @airport_departure_date_rfc822 = departure.present? ? departure.to_date.to_s(:rfc822) : @year.peak_departure_date.to_s(:rfc822)
  end

  def allow_only_self_or_admin
    allow = false
    if current_user.present?
      a = Attendee.find(params[:id].to_i)
      is_my_attendee = current_user.id.to_i == a.user_id
      allow = is_my_attendee || current_user.admin?
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

  def expose_selections
    params[:attendee] ||= {} # TODO: not sure we need this
    params[:activity_ids] ||= []
    @activity_selections = params[:activity_ids].map(&:to_i)
    @plan_selections = @plans.map { |p|
      Registration::PlanSelection.new p, plan_qty(p.id)
    }
  end

  def plan_qty plan_id
    params["plan_#{plan_id}_qty"].to_i # if nil, to_i returns 0
  end

  def redirect_to_terminus flash_notice
    flash[:notice] = flash_notice
    redirect_to user_terminus_path(:user_id => @attendee.user)
  end

  # `register_attendee` tries to save `@attendee` and its associated
  # records.  In addition to the validations defined in the model,
  # extra validations may add errors to `@attendee.errors[:base]`.
  def register_attendee
    reg = Registration::Registration.new(
      @attendee,
      current_user.admin?,
      params,
      @plan_selections,
      @activity_selections
    )
    errors = reg.save
    @attendee.errors[:base].concat(errors) unless errors.empty?
  end

  def render_form view
    expose_form_vars
    render view
  end

  # We do not want flash notices during initial registration
  def update_success_notice(page)
    %w[activities tournaments].include?(page) ? "Attendee updated" : nil
  end

  # `order_clause` validates the supplied sort field and
  # direction, and returns a sql order clause
  def order_clause
    return DEFAULT_ORDER unless SORTABLE_COLUMNS.include?(params[:sort])
    append_direction(anonymize_order(insensitive_order))
  end

  # Certain fields (eg. names) are sorted case-insensitivly
  def insensitive_order
    s = params[:sort]
    %w[given_name family_name].include?(s) ? "lower(#{s})" : s
  end

  def append_direction clause
    d = params[:direction]
    clause + (%w[asc desc].include?(d) ? " #{d}" : '')
  end

  # Some sort orders could reveal clues about anonymous people, so
  # we first order by anonymity to protect against that.
  def anonymize_order clause
    (sort_unsafe_for_anon?(params[:sort]) ? 'anonymous, ' : '') + clause
  end

  def sort_unsafe_for_anon? sort
    %w[given_name family_name country].include?(sort)
  end
end
