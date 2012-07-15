class AttendeesController < ApplicationController
  include SplitDatetimeParser
  include YearlyController

  # Callbacks, in order
  load_resource
  skip_load_resource :only => [:index, :vip]
  add_filter_to_set_resource_year
  authorize_resource
  skip_authorize_resource :only => [:create, :index, :vip]
  add_filter_restricting_resources_to_year_in_route

  # Actions
  def show
    @plan_categories = PlanCategory.reg_form(@year, @attendee.age_in_years)
  end

  def edit_plans
    init_plans
  end

  # `update_plans` replaces attendee_plan records in this category
  # with plans specified on the form, unless the maximum quantity
  # is exceeded.
  def update_plans
    init_plans
    params[:attendee] ||= {}
    vldn_errs = []

    # Build a new set of plans from the user's selections
    nascent_attendee_plans = []
    @plans.each do |p|
      qty = params[:attendee]["plan_#{p.id}_qty"].to_i # if nil, to_i returns 0
      if qty == 0

        # Only admins can remove previously selected disabled plans
        if p.disabled? && @attendee.has_plan?(p) && !current_user.admin?
          vldn_errs << "It looks like you're trying to remove a
            disabled plan (#{p.name}).  Please contact the registrar
            for help"
          ap_copy = @attendee.attendee_plans.where(plan_id: p.id).first.dup
          nascent_attendee_plans << ap_copy
        end

      elsif qty > 0
        ap = AttendeePlan.new(:attendee_id => @attendee.id, :plan_id => p.id, :quantity => qty)
        if ap.valid?

          # Only admins can add new disabled plans that weren't
          # previously selected
          if p.disabled? && !@attendee.has_plan?(p) && !current_user.admin?
            vldn_errs << "One of the plans you selected (#{ap.plan.name})
              is disabled. You cannot selected disabled plans.  In fact,
              you shouldn't have even been able to see it.  Please contact
              the registrar for help."
          else
            nascent_attendee_plans << ap
          end
        else
          vldn_errs.concat ap.errors.map {|k,v| k.to_s + " " + v.to_s}
        end
      end
    end

    @attendee.clear_plan_category!(@plan_category.id)

    unless nascent_attendee_plans.empty?
      @attendee.attendee_plans << nascent_attendee_plans
    end

    # Mandatory plan categories require at least one plan
    if @plan_category.mandatory? && nascent_attendee_plans.empty?
      vldn_errs << "This is a mandatory category, so please select at
        least one #{Plan.model_name.human.downcase}."
    end

    # if valid, go to next category or return to account
    if vldn_errs.empty? && @attendee.save
      reg_proc = RegistrationProcess.new @attendee
      redirect_to reg_proc.next_page(nil, @plan_category, session[:events_of_interest])
    else
      @attendee.errors[:base].concat vldn_errs
      render :edit_plans
    end
  end

  def index
    params[:direction] ||= "asc"
    @opposite_direction = (params[:direction] == 'asc') ? 'desc' : 'asc'
    @attendees = Attendee.yr(@year).with_at_least_one_plan
    @attendees = @attendees.order parse_order_clause_params
    @pro_count = @attendees.pro.count
    @dan_count = @attendees.dan.count
    @kyu_count = @attendees.kyu.count
  end

  def new

    # visitors cannot get the new attendee form
    unless current_user.present? then
      render_access_denied
      return
    end

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
  end

  def create

    # visitors cannot create attendees
    unless current_user.present? then
      render_access_denied
      return
    end

    # For which user are we creating this attendee?
    params[:attendee][:user_id] ||= current_user.id
    target_user_id = params[:attendee][:user_id].to_i
    target_user = User.find(target_user_id)

    # Only admins can create an attendee under a different user
    if (target_user.id != current_user.id) && !current_user.is_admin? then
      render_access_denied
      return
    end

    # Delete user_id from params hash to avoid mass-assignment warning
    params[:attendee].delete :user_id

    # Assign protected attributes
    @attendee.user_id = target_user.id
    @attendee.is_primary = (target_user.attendees.count == 0)
    @attendee.year = @year.year

    # Validate and save
    if @attendee.valid?
      @attendee.save!
      reg_proc = RegistrationProcess.new @attendee
      redirect_to reg_proc.next_page(:basics, nil, [])
    else
      init_multipage("basics")
      render :action => "new"
    end
  end

  def edit

    # there are too many attendee attributes to fit them all on
    # one form page. so, I've added a param called page
    @page = get_valid_page_from_params

    # only admins can see the admin page of the edit form
    if (@page == 'admin' && !current_user.is_admin?)
      render_access_denied and return
    end

    # Page-specific queries
    init_multipage(@page)

    # Render the specific page
    render get_view_name_from_page(@page)
  end

  def update
    @page = get_valid_page_from_params
    params[:attendee] ||= {}

    # some extra validation errors may come up, especially with
    # associated models, and we want to save these and add them
    # to @attendee.errors[:base] later.
    extra_errors = []

    if @page == 'admin'

      # certain fields may only be set by admins
      # most of those fields are shown on the 'admin' page
      render_access_denied and return unless current_user.is_admin?

      # admin-only fields
      [:comment, :minor_agreement_received].each do |p|
        if (!params[:attendee][p].nil?)
          @attendee[p] = params[:attendee][p]
          params[:attendee].delete p
        end
      end

      # Invitational tournaments
      @attendee.tournaments.delete( @attendee.tournaments.where(:openness=>'I') )
      params[:attendee][:tournament_id_list] ||= Array.new
      params[:attendee][:tournament_id_list].each do |tid|
        t = Tournament.where("openness = ?", 'I').find(tid)
        @attendee.tournaments << t if t.present?
      end
      params[:attendee].delete :tournament_id_list

    elsif @page == 'events'

      # Persist the selected events in the session
      params[:event_ids] ||= []
      if params[:event_ids].empty?
        extra_errors << "Please pick at least one event"
      else
        session[:events_of_interest] = params[:event_ids]
        raise ArgumentError unless session[:events_of_interest].respond_to? :each
      end

      # Assign airport_arrival and airport_departure attributes, if possible
      extra_errors.concat parse_airport_datetimes

    elsif (@page == 'wishes')

      # claimed discounts
      params[:attendee][:discount_ids] ||= Array.new

      # ignore non-integer discount ids (from unchecked boxes in the view)
      valid_discount_ids = params[:attendee][:discount_ids].delete_if {|d| d.to_i == 0}

      # assign discounts, provided they are non-automatic
      # (only non-automatic discounts may be set by users)
      discounts = Discount.where('is_automatic = ? and id in (?)', false, valid_discount_ids)
      @attendee.discounts.clear
      @attendee.discounts << discounts

      # delete param to avoid attr_accessible warning
      params[:attendee].delete :discount_ids

    elsif (@page == 'tournaments')
      @attendee.tournaments.delete( @attendee.tournaments.where(:openness=>'O') )
      params[:attendee][:tournament_id_list] ||= Array.new
      params[:attendee][:tournament_id_list].each do |tid|
        t = Tournament.where("openness = ?", 'O').find(tid)
        if t.present? then
          at = AttendeeTournament.new(:attendee_id => @attendee.id, :tournament_id => t.id)
          if t.show_attendee_notes_field then
            if params[:attendee]["trn_#{t.id}_notes"].present? then
              at.notes = params[:attendee]["trn_#{t.id}_notes"]
              params[:attendee].delete "trn_#{t.id}_notes"
            end
          end
          if at.valid?
            at.save!
          else
            at.errors.each { |k,v| extra_errors << k.to_s + " " + v.to_s }
          end
        end
      end
      params[:attendee].delete :tournament_id_list

    elsif (@page == 'activities')
      activity_id_array = params[:attendee][:activity_id_list] || []
      @attendee.replace_all_activities(activity_id_array)
      params[:attendee].delete :activity_id_list
    end

    # update attributes but do not save yet
    @attendee.attributes = params[:attendee]

    # validate
    if @attendee.valid? && extra_errors.empty?
      @attendee.save(:validate => false)
      reg_proc = RegistrationProcess.new @attendee
      redirect_to reg_proc.next_page(@page, nil, session[:events_of_interest]), :notice => update_success_notice(@page)
    else
      init_multipage(@page)
      @attendee.errors[:base].concat extra_errors
      render get_view_name_from_page(@page)
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
    tmt_names = AttendeeTournament.tmt_names_by_attendee(@year.year)
    @tmt_names_atn = tmt_names[@attendee.id].present? ? tmt_names[@attendee.id] : Array.new
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

  def init_multipage( page )
    if page == "events"
      arrival = @attendee.airport_arrival
      @airport_arrival_date = arrival.present? ? arrival.to_date : nil
      @airport_arrival_time = arrival.present? ? arrival.to_s(:american).strip : nil
      @airport_arrival_date_rfc822 = arrival.present? ? arrival.to_date.to_s(:rfc822) : @year.start_date.to_s(:rfc822)
      departure = @attendee.airport_departure
      @airport_departure_date = departure.present? ? departure.to_date : nil
      @airport_departure_time = departure.present? ? departure.to_s(:american).strip : nil
      @airport_departure_date_rfc822 = departure.present? ? departure.to_date.to_s(:rfc822) : @year.peak_departure_date.to_s(:rfc822)
    elsif page == "wishes"
      @discounts = Discount.yr(@year).automatic(false)
      @attendee_discount_ids = @attendee.discounts.automatic(false).map { |d| d.id }
    elsif page == "admin"
      @invitational_tournaments = Tournament.yr(@year).openness('I')
      @atnd_inv_trn_ids = @attendee.tournaments.openness('I').map {|t| t.id}
    elsif page == "tournaments"
      @open_tournaments = Tournament.yr(@year).openness('O').order(:name)
      @atnd_open_trn_ids = @attendee.tournaments.openness('O').map {|t| t.id}
    elsif page == "activities"
      @activities = Activity.yr(@year).order(:leave_time, :name)
      @atnd_activity_ids = @attendee.activities.map {|e| e.id}
    end
  end

  def init_plans
    @plan_category = PlanCategory.reg_form(@year, @attendee.age_in_years).find(params[:plan_category_id])
    age = @attendee.age_in_years

    # Which plans to show?  Admins can always see disabled plans,
    # but users only see disabled plans if they had already
    # selected such a plan, eg. back when it was enabled. Regardless
    # of user level, only plans appropriate to the attendee's age
    # are shown.
    @plans = @plan_category.plans.appropriate_for_age(age).rank :cat_order
    unless current_user.admin?
      @plans.delete_if {|p| p.disabled? && !@attendee.has_plan?(p)}
    end

    @show_availability = Plan.inventoried_plan_in? @plans
    @show_quantity_instructions = Plan.quantifiable_plan_in? @plans
  end

  def get_valid_page_from_params
    page = params[:page].to_s.blank? ? 'basics' : params[:page].to_s
    Attendee.assert_valid_page(page)
    return page
  end

  def get_view_name_from_page( page )
    Attendee.assert_valid_page(page)
    if %w[admin terminus wishes].include?(page.to_s)
      view_name = page.to_s
    elsif page == "basics"
      view_name = "edit"
    elsif %w[events tournaments activities].include? page
      view_name = "edit_#{page}"
    else
      raise "No view for page: #{page}"
    end
    return view_name
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

  def parse_airport_datetimes
    parse_errors = []
    begin
      @attendee.airport_arrival = parse_split_datetime(params[:attendee], :airport_arrival)
      @attendee.airport_departure = parse_split_datetime(params[:attendee], :airport_departure)
    rescue SplitDatetimeParserException => e
      parse_errors << e.to_s
    end
    return parse_errors
  end

  # We do not want flash notices during initial registration
  def update_success_notice(page)
    %w[activities tournaments].include?(page) ? "Attendee updated" : nil
  end

  # `parse_order_clause_params` validates the supplied sort field and
  # direction, and returns an sql order clause string.  If no valid
  # sort field is supplied, the default is to sort by rank (0 is non-player).
  def parse_order_clause_params
    valid_sortable_columns = %w[given_name family_name rank created_at country state]
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
      unsafe_for_anon = %w[given_name family_name country state]
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
