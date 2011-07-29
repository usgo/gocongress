class AttendeesController < ApplicationController

  load_and_authorize_resource
  skip_load_resource :only => [:index, :vip]
  skip_authorize_resource :only => [:create, :index, :new, :vip]
  
  def index
    # by default, sort by rank (0 is non-player)
    order_by_clause = "rank = 0, rank desc"

    # if a sort order was specified, make sure it is not a SQL injection attack
    valid_sortable_columns = %w[given_name family_name rank created_at country]
    if (valid_sortable_columns.include?(params[:sort])) then
      order_by_clause = params[:sort]
    end

    # some sort orders could reveal clues about anonymous people,
    # so we must first order by anonymity to protect against that -Jared
    unsafe_for_anon = %w[given_name family_name]
    if (unsafe_for_anon.include?(order_by_clause)) then
      order_by_clause = 'anonymous, ' + order_by_clause
    end

    # get all attendees
    @attendees = Attendee.order order_by_clause

    # We are also going to show the list of pre-registrants, at least for now.
    # Obviously, at some point they will all hopefully sign up for real user accounts
    # and then this list will be defunct. -Jared 1/23/11
    @preregistrants = Preregistrant.order('preregdate asc')

    # get some fun statistics
    @pro_count = Attendee.where("rank IN (?)", (101)..(109)).count
    @dan_count = Attendee.where("rank IN (?)", (1)..(9)).count
    @kyu_count = Attendee.where("rank IN (?)", (-30)..(-1)).count
    @np_count = Attendee.where(:rank => 0).count
    @youngest_attendee = Attendee.reasonable_birth_date.order('birth_date desc').first
    @oldest_attendee = Attendee.reasonable_birth_date.order('birth_date desc').last
    @male_count = Attendee.where(:gender => 'm').count
    @female_count = Attendee.where(:gender => 'f').count
    
    total_seconds_of_life = 0
    Attendee.reasonable_birth_date.each do |a|
      total_seconds_of_life += a.age_in_seconds
    end
    avg_age_in_seconds = total_seconds_of_life.to_f / Attendee.reasonable_birth_date.count
    @avg_age_in_years = avg_age_in_seconds.to_f / 60 / 60 / 24 / 365
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
    if @attendee.save
      # After successful save, redirect to the "Edit Go Info" form
      # We are afraid if we do not, then no one will fill it out -Jared
      redirect_to(edit_attendee_path(@attendee.id) + "/baduk")
    else
      render :action => "new"
    end
  end

  # GET /attendees/1/edit/basics
  # GET /attendees/1/edit/baduk
  # GET /attendees/1/edit/roomboard
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

      # for each simple "admin-only" field
      [:comment, :confirmed, :minor_agreement_received, :guardian_full_name].each do |p|
        if (!params[:attendee][p].nil?)
          @attendee[p] = params[:attendee][p]
          params[:attendee].delete p
        end
      end

      # deposit_received_at is not as simple
      if (params[:attendee][:"deposit_received_at(1i)"].present? &&
          params[:attendee][:"deposit_received_at(2i)"].present? &&
          params[:attendee][:"deposit_received_at(3i)"].present?) \
      then
        @attendee.deposit_received_at = convert_date(params[:attendee], :deposit_received_at)
        params[:attendee].delete :"deposit_received_at(1i)"
        params[:attendee].delete :"deposit_received_at(2i)"
        params[:attendee].delete :"deposit_received_at(3i)"
      else
        @attendee.deposit_received_at = nil
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

    elsif (@page == 'roomboard')

      # handle selected plans
      # to do: this causes a lot of little queries. surely there's a better way.
          
      # start with a blank slate
      @attendee.plans.clear
      
      # for each plan, has the attendee provided a quantity?
      # to do: only consider plans appropriate for this attendee and shown on the form
      Plan.all.each do |p|
      
        # get quantity for this plan.  if quantity is undefined, to_i will return 0
        qty = params[:attendee]["plan_#{p.id}_qty"].to_i
        
        # if the quantity is nonzero, create it!
        if qty > 0 then
          ap = AttendeePlan.new(:attendee_id => @attendee.id, :plan_id => p.id, :quantity => qty)
          if ap.valid?
            @attendee.attendee_plans << ap
          else
            ap.errors.each { |k,v| extra_errors << k.to_s + " " + v.to_s }
          end
        end
      end

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
        redirect_to(edit_attendee_path(@attendee.id) + "/roomboard")
      else
        redirect_to user_path(@attendee.user_id), :notice => "Attendee successfully updated"
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
    @attendees = Attendee.where('rank >= 101')
  end

protected

  def init_multipage( page )
    if page == "baduk"
      @discounts = Discount.where("is_automatic = ?", false)
      @attendee_discount_ids = @attendee.discounts.map { |d| d.id }
    elsif page == "roomboard"
      age = @attendee.age_in_years.to_i
      @plans_ordered = Plan.reg_form.appropriate_for_age(age).order("price desc")
      @plans_grouped = @plans_ordered.group_by {|plan| plan.plan_category}
    elsif page == "admin"
      @invitational_tournaments = Tournament.where :openness => 'I'
      @atnd_inv_trn_ids = @attendee.tournaments.where({:openness => 'I'}).map {|t| t.id}
    elsif page == "tournaments"
      @open_tournaments = Tournament.where(:openness => 'O').order(:name)
      @atnd_open_trn_ids = @attendee.tournaments.where({:openness => 'O'}).map {|t| t.id}
    elsif page == "events"
      @events = Event.order(:start, :evtname)
      @atnd_event_ids = @attendee.events.map {|e| e.id}
    end
  end

  def get_valid_page_from_params
    params[:page].to_s.blank? ? page = 'basics' : page = params[:page].to_s
    unless %w[admin basics baduk roomboard tournaments events].include?(page) then raise 'invalid page' end
    return page
  end
  
  def get_view_name_from_page( page )
    if page == "admin"
      view_name = "admin"
    elsif page == "basics"
      view_name = "edit"
    elsif page == "baduk"
      view_name = "edit_baduk_info"
    elsif page == "roomboard"
      view_name = "room_and_board"
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
