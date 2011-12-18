class AttendeesController < ApplicationController

  load_and_authorize_resource
  skip_load_resource :only => [:index, :vip]
  skip_authorize_resource :only => [:create, :index, :new, :vip]

  def show
    @plan_categories = PlanCategory.reg_form(@year)
  end

  def edit_plans
    init_plans
  end

  def update_plans
    init_plans
    params[:attendee] ||= {}
    vldn_errs = []

    # Replace attendee_plan records in this category with plans specified
    # on the form, unless the maximum quantity is exceeded.
    @attendee.clear_plan_category!(@plan_category.id)
    @plans.each do |p|
      qty = params[:attendee]["plan_#{p.id}_qty"].to_i # if nil, to_i returns 0
      if qty > 0 then
        ap = AttendeePlan.new(:attendee_id => @attendee.id, :plan_id => p.id, :quantity => qty)
        if ap.valid?
          @attendee.attendee_plans << ap
        else
          vldn_errs.concat ap.errors.map {|k,v| k.to_s + " " + v.to_s}
        end
      end
    end

    # if valid, go to next category or return to account
    if vldn_errs.length == 0 && @attendee.save
      cats = PlanCategory.reg_form(@year).all
      next_category = cats[1 + cats.index(@plan_category)]
      if next_category.present?
        redirect_to edit_plans_for_attendee_path(@attendee, next_category)
      else
        redirect_to attendee_path(@attendee), :notice => "Changes saved"
      end
    else
      @attendee.errors[:base].concat vldn_errs
      render :edit_plans
    end
  end

  def index
    params[:direction] ||= "asc"
    @opposite_direction = (params[:direction] == 'asc') ? 'desc' : 'asc'

    # if a sort order was specified, make sure it is not a SQL injection attack
    valid_sortable_columns = %w[given_name family_name rank created_at country]
    if (valid_sortable_columns.include?(params[:sort])) then
      order_clause = params[:sort]

      # some sort orders could reveal clues about anonymous people,
      # so we must first order by anonymity to protect against that -Jared
      unsafe_for_anon = %w[given_name family_name]
      if (unsafe_for_anon.include?(order_clause)) then
        order_clause = 'anonymous, ' + order_clause
      end

      # sort direction
      valid_directions = %w[asc desc]
      if valid_directions.include?(params[:direction]) then
        order_clause += " " + params[:direction]
      end

    else

      # by default, sort by rank (0 is non-player)
      order_clause = "rank = 0, rank desc"
    end

    # get all attendees
    @attendees = Attendee.yr(@year).order(order_clause)

    # get some fun statistics
    @pro_count = @attendees.where(:rank => 101..109).count
    @dan_count = @attendees.where(:rank => 1..9).count
    @kyu_count = @attendees.where(:rank => -30..-1).count
    @np_count = @attendees.where(:rank => 0).count
    @male_count = @attendees.where(:gender => 'm').count
    @female_count = @attendees.where(:gender => 'f').count
    
    # for the age statistics, our query will use a different order clause
    age_before_beauty = Attendee.yr(@year).reasonable_birth_date.order('birth_date')
    @oldest_attendee = age_before_beauty.first
    @youngest_attendee = age_before_beauty.last

    # calculate average age
    aged_attendees = @attendees.reasonable_birth_date.all
    total_years_of_life = aged_attendees.map(&:age_in_years).reduce(:+)
    @avg_age = total_years_of_life / aged_attendees.count
  end

  # GET /attendees/new
  # GET /users/:id/attendees/new
  def new

    # visitors cannot get the new attendee form
    unless current_user.present? then
      render_access_denied
      return
    end

    # Which user are we adding this new attendee to?
    target_user_id = params[:id].present? ? params[:id].to_i : current_user.id

    # Only admins can add attendees to other users
    if !current_user.is_admin? && target_user_id != current_user.id then
      render_access_denied
      return
    end

    # Instantiate a blank attendee for the target user
    @attendee.user_id = target_user_id

    # Copy certain fields from the target user's primary_attendee
    target_user = User.find(target_user_id)
    ['phone','address_1','address_2','city','state','zip','country','phone','email'].each { |f|
      @attendee[f] = target_user.primary_attendee[f]
    }
  end
  
  # POST /attendees
  def create

    # visitors cannot create attendees
    unless current_user.present? then
      render_access_denied
      return
    end

    # For which user are we creating this attendee?
    params[:attendee][:user_id] ||= current_user.id
    target_user_id = params[:attendee][:user_id].to_i

    # Delete user_id from params hash to avoid attr_accessible mass-assignment warning
    params[:attendee].delete :user_id

    # Only admins can create an attendee under a different user
    if (target_user_id != current_user.id) && !current_user.is_admin? then
      render_access_denied
      return
    end

    @attendee.user_id = target_user_id
    @attendee.year = @year
    if @attendee.save
      # After successful save, redirect to the "Edit Go Info" form
      # We are afraid if we do not, then no one will fill it out
      redirect_to edit_attendee_path(@attendee, :baduk)
    else
      render :action => "new"
    end
  end

  # GET /attendees/1/edit/basics
  # GET /attendees/1/edit/baduk
  # GET /attendees/1/edit/tournaments
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

  # PUT /attendees/1
  def update
    @page = get_valid_page_from_params
    params[:attendee] ||= Hash.new

    # some extra validation errors may come up, especially with associated models, and
    # we want to save these and add them to @attendee.errors[:base] later.  This
    # produces better-looking, more meaningful validation error display -Jared
    extra_errors = []

    # certain fields may only be set by admins
    # most of those fields are shown on the 'admin' page
    if (@page == 'admin')
      render_access_denied and return unless current_user.is_admin?

      # admin-only fields
      [:comment, :confirmed, :minor_agreement_received, :guardian_full_name].each do |p|
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

    elsif (@page == 'baduk')
      
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

    elsif (@page == 'events')
      @attendee.events.clear
      params[:attendee][:event_id_list] ||= Array.new
      params[:attendee][:event_id_list].each do |eid|
        e = Event.find(eid)
        @attendee.events << e if e.present?
      end
      params[:attendee].delete :event_id_list
    end

    # update attributes but do not save yet
    @attendee.attributes = params[:attendee]

    # run the appropriate validations for this @page 
    if @attendee.valid_in_form_page?(@page.to_sym) and extra_errors.length == 0
      @attendee.save(:validate => false)

      # after saving the baduk page, if the attendee has not selected a plan yet,
      # then go to the roomboard page, else return to "my account"
      if @page == 'baduk' && @attendee.plans.count == 0
        category = PlanCategory.order(:name).first
        redirect_to edit_plans_for_attendee_path(@attendee, category)
      else
        redirect_to attendee_path(@attendee), :notice => "Attendee updated"
      end
    else
      init_multipage(@page)
      extra_errors.each { |e| @attendee.errors[:base] << e }
      render get_view_name_from_page(@page)
    end
  end

  # DELETE /attendees/1
  def destroy
    belonged_to_current_user = (current_user.id == @attendee.user_id)

    # only admins can destroy primary attendees
    if @attendee.is_primary? and !current_user_is_admin? then
      render_access_denied
      return
    end

    target_attendee_user_id = @attendee.user_id
    @attendee.destroy
    flash[:notice] = "Attendee deleted"
    redirect_to user_path(target_attendee_user_id)
  end

  # GET /attendees/1/print_summary
  def print_summary
    @attendee = Attendee.find params[:id]
    authorize! :read, @attendee
    @attendee_attr_names = %w[aga_id birth_date comment confirmed email gender phone special_request roomate_request].sort
    tmt_names = AttendeeTournament.tmt_names_by_attendee
    @tmt_names_atn = tmt_names[@attendee.id].present? ? tmt_names[@attendee.id] : Array.new
    render :layout => "print"
  end

  # GET /attendees/1/print_badge
  def print_badge
    @attendee = Attendee.find params[:id]
    authorize! :read, @attendee
    render :layout=> 'print'
  end
  
  # GET /attendees/vip
  def vip
    @attendees = Attendee.yr(@year).where('rank >= 101')
  end

protected

  def init_multipage( page )
    if page == "baduk"
      @discounts = Discount.yr(@year).automatic(false)
      @attendee_discount_ids = @attendee.discounts.automatic(false).map { |d| d.id }
    elsif page == "admin"
      @invitational_tournaments = Tournament.yr(@year).openness('I')
      @atnd_inv_trn_ids = @attendee.tournaments.openness('I').map {|t| t.id}
    elsif page == "tournaments"
      @open_tournaments = Tournament.yr(@year).openness('O').order(:name)
      @atnd_open_trn_ids = @attendee.tournaments.openness('O').map {|t| t.id}
    elsif page == "events"
      @events = Event.yr(@year).order(:start, :evtname)
      @atnd_event_ids = @attendee.events.map {|e| e.id}
    end
  end
  
  def init_plans
    @plan_category = PlanCategory.reg_form(@year).find(params[:plan_category_id])
    age = @attendee.age_in_years
    @plans = @plan_category.plans.appropriate_for_age(age).order("price desc")
  end

  def get_valid_page_from_params
    params[:page].to_s.blank? ? page = 'basics' : page = params[:page].to_s
    unless %w[admin basics baduk tournaments events].include?(page) then raise 'invalid page' end
    return page
  end
  
  def get_view_name_from_page( page )
    if page == "admin"
      view_name = "admin"
    elsif page == "basics"
      view_name = "edit"
    elsif page == "baduk"
      view_name = "edit_baduk_info"
    elsif page == "tournaments"
      view_name = "edit_tournaments"
    elsif page == "events"
      view_name = "edit_events"
    else
      raise "invalid page"
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

end
