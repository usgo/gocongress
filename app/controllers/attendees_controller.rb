class AttendeesController < ApplicationController

  # Access Control
  before_filter :allow_only_admin, :except => [:create, :destroy, :edit, :index, :new, :update, :vip]
  before_filter :allow_only_self_or_admin, :only => [:destroy, :edit, :update]
  
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
    @attendees = Attendee.order(order_by_clause)

    # We are also going to show the list of pre-registrants, at least for now.
    # Obviously, at some point they will all hopefully sign up for real user accounts
    # and then this list will be defunct. -Jared 1/23/11
    @preregistrants = Preregistrant.order('preregdate asc')

    # get some fun statistics
    @dan_count = Attendee.where("rank IN (?)", (1)..(9)).count
    @kyu_count = Attendee.where("rank IN (?)", (-30)..(-1)).count
    @np_count = Attendee.where(:rank => 0).count
    @youngest_attendee = Attendee.reasonable_birth_date.order('birth_date desc').first
    @oldest_attendee = Attendee.reasonable_birth_date.order('birth_date desc').last
    @male_count = Attendee.where(:gender => 'm').count
    @female_count = Attendee.where(:gender => 'f').count
  end

  # GET /attendees/new
  def new

    # visitors can not get the new attendee form
    unless current_user.present? then
      render_access_denied
      return
    end

    # copy over certain fields from the primary_attendee -Jared
    @attendee = Attendee.new
    ['phone','address_1','address_2','city','state','zip','country','phone','email'].each { |f|
      @attendee[f] = current_user.primary_attendee[f]
    }
  end
  
  # POST /attendees
  def create

    # visitors can not create attendees
    unless current_user.present? then
      render_access_denied
      return
    end

    # no-one can create an attendee under a different user
    if params[:attendee][:user_id].present? and params[:attendee][:user_id] != current_user.id then
      render_access_denied
      return
    end

    @attendee = Attendee.new(params[:attendee])
    @attendee.user_id = current_user.id
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
  def edit
    @attendee = Attendee.find_by_id(params[:id].to_i)
    
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
    @attendee = Attendee.find(params[:id])

    # certain fields may only be set by admins
    if (@page == 'admin')
      if (!current_user.is_admin?)
        render_access_denied and return
      else

        # comment
        if (!params[:attendee][:comment].nil?)
          @attendee.comment = params[:attendee][:comment]
          params[:attendee].delete :comment
        end

        # deposit_received_at
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
      end
    end

    # handle claimed discounts
    if (@page == 'baduk')
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
    end

    # update attributes but do not save yet
    @attendee.attributes = params[:attendee]

    # run the appropriate validations for this @page 
    if @attendee.valid_in_form_page?(@page.to_sym)
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
      render get_view_name_from_page(@page)
    end
  end

  # DELETE /attendees/1
  def destroy
    target_attendee = Attendee.find(params[:id])
    belonged_to_current_user = (current_user.id == target_attendee.user_id)

    # only admins can destroy primary attendees
    if target_attendee.is_primary and !current_user_is_admin? then
      render_access_denied
      return
    end

    target_attendee.destroy
    flash[:notice] = "Attendee deleted"
    if belonged_to_current_user
      redirect_to user_path(current_user)
    else
      redirect_to users_path
    end
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
      @plans_ordered = Plan.reg_form.appropriate_for_age(age).order("has_rooms desc, price desc")
      @plans_grouped = @plans_ordered.group_by {|plan| plan.plan_category}
      @attendee_plan_ids = @attendee.plans.map {|p| p.id}
    end
  end

  def get_valid_page_from_params
    params[:page].to_s.blank? ? page = 'basics' : page = params[:page].to_s
    unless %w[admin basics baduk roomboard].include?(page) then raise 'invalid page' end
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
    else
      raise "invalid page"
    end
    return view_name
  end

  def allow_only_self_or_admin
    target_attendee = Attendee.find_by_id(params[:id].to_i)
    unless target_attendee.present? && current_user && (current_user.id.to_i == target_attendee.user_id || current_user.is_admin?)
      render_access_denied
    end
  end

end
