class AttendeesController < ApplicationController

  # Access Control
  before_filter :allow_only_admin, :except => [:create, :index, :new, :edit, :update]
  before_filter :allow_only_self_or_admin, :only => [:edit, :update]
  
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
  end

  # GET /attendees/new
  def new
    @attendee = Attendee.new

    # copy over certain fields from the primary_attendee -Jared
    ['phone','address_1','address_2','city','state','zip','country','phone','email'].each { |f|
      @attendee[f] = current_user.primary_attendee[f]
    }
  end
  
  # POST /attendees
  def create
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
    
    # there are too many attendee attributes to fit them all on one form page
    # so, I've added a param called page.  Alf, would you have done this differently?
    # Thanks, -Jared 2011.01.08
    @page = get_valid_page_from_params
    render get_view_name_from_page(@page)
  end

  # PUT /attendees/1
  def update
    @page = get_valid_page_from_params
    @attendee = Attendee.find(params[:id])
    
    # update attributes but do not save yet
    @attendee.attributes = params[:attendee]
    
    # run the appropriate validations for this @page 
    if @attendee.valid_in_form_page?(@page.to_sym)
      @attendee.save(:validate => false)
      redirect_to user_path(@attendee.user_id), :notice => "Attendee successfully updated"
    else
      render get_view_name_from_page(@page)
    end
  end

  # DELETE /attendees/1
  def destroy
    target_attendee = Attendee.find(params[:id])
    belonged_to_current_user = (current_user.id == target_attendee.user_id)

    # primary attendees can never be deleted
    # will this be a problem when we implement user deletion?
    if target_attendee.is_primary then
      render_access_denied
      return
    end

    target_attendee.destroy
    flash[:notice] = "Attendee deleted"
    if belonged_to_current_user
      redirect_to user_path(current_user)
    else
      redirect_to attendees_path
    end
  end

protected

  def get_valid_page_from_params
    params[:page].to_s.blank? ? page = 'basics' : page = params[:page].to_s
    unless %w[basics baduk roomboard].include?(page) then raise 'invalid page' end
    return page
  end
  
  def get_view_name_from_page( page )
    if page == "basics"
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
